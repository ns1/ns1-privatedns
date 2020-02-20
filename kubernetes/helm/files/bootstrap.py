#!/usr/bin/env python
import http.client
import json
import os
import ssl
import subprocess
import sys
from pprint import pprint
from urllib.parse import urlencode

subprocess.check_call([sys.executable, "-m", "pip", "install", "kubernetes"])

import kubernetes.client, kubernetes.config
from kubernetes.client.rest import ApiException

NAMESPACE = os.environ.get("KUBERNETES_NAMESPACE", "ns1")
HOST = os.environ.get("BOOTSTRAP_HOST", "core")
PORT = os.environ.get("BOOTSTRAP_PORT", 80)
BOOTSTRAP_USER = os.environ.get("BOOTSTRAP_USER", "nsone")
BOOTSTRAP_PASSWORD = os.environ.get("BOOTSTRAP_PASSWORD", "secure-password")
FIRST_USER = os.environ.get("FIRST_USER", "ns1")
FIRST_USER_PASSWORD = os.environ.get("FIRST_USER_PASSWORD", "privatedns")


def request(method, domain, path="/", **kwargs):
    if domain.startswith("https://"):
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        conn = http.client.HTTPSConnection(domain[8:], PORT, context=ctx)
    else:
        conn = http.client.HTTPConnection(domain, PORT)

    if isinstance(kwargs, dict) and kwargs.get("params"):
        if method in ("POST", "PUT"):
            kwargs["body"] = json.dumps(kwargs["params"])
            del kwargs["params"]
        else:
            kwargs["params"] = urlencode(kwargs["params"])

    print(method, path, kwargs, domain)
    conn.request(method, path, **kwargs)
    response = conn.getresponse()
    if response.status != 200:
        fail(
            "Got an error response processing {}\n\tcode: {}\n\treason: {}\n\tmsg: {}".format(
                path, response.status, response.reason, response.read()
            )
        )

    try:
        result = json.loads(response.read().decode("utf-8"))
    except Exception as e:
        fail("failed to convert api response to json: {}".format(e))
    finally:
        conn.close()

    return result


class BootstrapError(Exception):
    pass


class BootstrapManager(object):
    def __init__(self, domain):
        self.url = domain

    def bootstrap_operator(self):
        return request(
            "POST",
            self.url,
            "/v1/ops/bootstrap",
            params={
                "user": BOOTSTRAP_USER,
                "name": "Root Operator",
                "email": "dev@ns1.com",
                "password": BOOTSTRAP_PASSWORD,
            },
        )

    def create_network(self, operator):
        return request(
            "PUT",
            self.url,
            "/v1/ops/service/groups",
            params={"name": "Network0", "type": "core", "properties": {},},
            headers={"X-NSONE-Key": operator["key"]},
        )

    def create_service(self, operator, name, network, org):
        return request(
            "PUT",
            self.url,
            "/v1/ops/service/defs",
            params={
                "name": name,
                "type": "DHCP",
                "service_group_id": network["id"],
            },
            headers={"X-NSONE-Key": operator["key"]},
        )

    def create_scopegroup(self, operator, name, network, org):
        return request(
            "PUT",
            self.url,
            "/v1/dhcp/scopegroup",
            params={
                "name": name,
                "service_group_id": network["id"],
                "dhcpv4": {},
                "dhcpv6": {},
            },
            headers={
                "X-NSONE-Key": "{}!{}".format(operator["key"], org["id"])
            },
        )

    def create_dns_pool(self, operator, network):
        return request(
            "PUT",
            self.url,
            "/v1/ops/service/defs",
            params={
                "name": "p00",
                "type": "DNS",
                "properties": {"nameservers": ["ns1.internal"],},
                "service_group_id": network["id"],  # implicit assignation
            },
            headers={"X-NSONE-Key": operator["key"]},
        )

    def create_org(self, operator, network):
        org = request(
            "PUT",
            self.url,
            "/v1/ops/orgs",
            params={"name": "NS1 Org",},
            headers={"X-NSONE-Key": operator["key"]},
        )
        assoc_sg = "/v1/ops/service/groups/{}/org/{}".format(
            network["id"], org["id"]
        )
        request(
            "POST",
            self.url,
            assoc_sg,
            headers={"X-NSONE-Key": operator["key"]},
        )
        return org

    def create_org_user(self, operator, org, name=None):
        user = request(
            "PUT",
            self.url,
            "/v1/account/users/{}".format(name),
            params={
                "username": name,
                "email": name + "@example.com",
                "name": "First User",
                "teams": [],
                "permissions": {
                    "data": {
                        "push_to_datafeeds": True,
                        "manage_datafeeds": True,
                        "manage_datasources": True,
                    },
                    "account": {
                        "view_activity_log": True,
                        "manage_teams": True,
                        "manage_apikeys": True,
                        "manage_users": True,
                        "manage_account_settings": True,
                    },
                    "dns": {
                        "zones_allow": ["example.com"],
                        "zones_deny": [],
                        "zones_allow_by_default": True,
                        "manage_zones": True,
                        "view_zones": True,
                    },
                    "ipam": {"view_ipam": True, "manage_ipam": True},
                    "dhcp": {"view_dhcp": True, "manage_dhcp": True},
                },
            },
            headers={
                "X-NSONE-Key": "{}!{}".format(operator["key"], org["id"])
            },
        )
        invite = request(
            "GET", self.url, "/v1/invite/{}".format(user["invite_token"])
        )
        request(
            "POST",
            self.url,
            "/v1/invite/{}".format(user["invite_token"]),
            headers={"X-NSONE-Key": invite["key"]},
            params={
                "password": FIRST_USER_PASSWORD,
                "username": FIRST_USER,
                "name": "First User",
            },
        )
        user.update({"password": FIRST_USER_PASSWORD})
        return user

    def create_org_apikey(self, operator, org):
        return request(
            "PUT",
            self.url,
            "/v1/account/apikeys",
            params={
                "permissions": {
                    "data": {
                        "push_to_datafeeds": True,
                        "manage_datafeeds": True,
                        "manage_datasources": True,
                    },
                    "account": {
                        "view_activity_log": True,
                        "manage_teams": True,
                        "manage_apikeys": True,
                        "manage_users": True,
                        "manage_account_settings": True,
                    },
                    "dns": {
                        "zones_allow": ["example.com"],
                        "zones_allow_by_default": True,
                        "manage_zones": True,
                        "view_zones": True,
                    },
                    "ipam": {"view_ipam": True, "manage_ipam": True},
                    "dhcp": {"view_dhcp": True, "manage_dhcp": True},
                },
                "teams": [],
                "name": "My API Key",
            },
            headers={
                "X-NSONE-Key": "{}!{}".format(operator["key"], org["id"])
            },
        )


def fail(*args):
    print("[!] ERROR: {}\n".format(*args))
    sys.exit(1)


def main():

    mgr = BootstrapManager(HOST)

    try:
        operator = mgr.bootstrap_operator()
        if not operator:
            fail("Could not create operator")

        configmap_data = {}

        print("Operator")
        print("  Name: {}".format(operator["name"]))
        print("  Key:  {}".format(operator["key"]))
        print("  2FA:  {}\n".format(operator["two_factor_auth"]["secret"]))
        configmap_data["operator_name"] = operator["name"]
        configmap_data["operator_key"] = operator["key"]
        configmap_data["operator_2fa"] = operator["two_factor_auth"]["secret"]

        network = mgr.create_network(operator)
        if not network:
            fail("could not create network (service group)")
        print("Network (Service Group)")
        print("  ID:   {}".format(network["id"]))
        print("  Name: {}\n".format(network["name"]))
        configmap_data["network_id"] = str(network["id"])
        configmap_data["network_name"] = network["name"]

        dns_pool = mgr.create_dns_pool(operator, network)
        if not dns_pool:
            fail("could not create dns pool")

        print("DNS Pool (Service Def)")
        print("  ID:   {}".format(dns_pool["id"]))
        print("  Name: {}\n".format(dns_pool["name"]))
        configmap_data["service_def_id"] = str(dns_pool["id"])
        configmap_data["service_def_name"] = dns_pool["name"]

        org = mgr.create_org(operator, network)
        if not org:
            fail("could not create organization")

        print("Organization")
        print("  ID:   {}".format(org["id"]))
        print("  Name: {}\n".format(org["name"]))
        configmap_data["organization_id"] = str(org["id"])
        configmap_data["organization_name"] = org["name"]

        apikey = mgr.create_org_apikey(operator, org)
        if not apikey:
            fail("could not create api key")

        print("ApiKey (Org)")
        print("  Key: {}\n".format(apikey["key"]))
        configmap_data["api_key_id"] = apikey["key"]

        user = mgr.create_org_user(operator, org, name=FIRST_USER)
        if not user:
            fail("could not create user")

        print("Portal User (Org)")
        print("  Name: {}".format(user["username"]))
        print("  Password: {}\n".format(user["password"]))
        configmap_data["portal_user_username"] = user["username"]
        configmap_data["portal_user_password"] = user["password"]

        for i in range(1, 10):
            mgr.create_scopegroup(
                operator, "example_scope-{}".format(i), network, org
            )

        service = mgr.create_service(operator, "dhcpdemo1", network, org)
        service = mgr.create_service(operator, "dhcpdemo2", network, org)

        kubernetes.config.load_incluster_config()
        k8s = kubernetes.client.CoreV1Api()

        configmap_meta = kubernetes.client.V1ObjectMeta(
            name="ns1-bootstrap-credentials"
        )
        configmap_body = kubernetes.client.V1ConfigMap(
            data=configmap_data, metadata=configmap_meta
        )

        try:
            k8s_response = k8s.replace_namespaced_config_map(
                "ns1-bootstrap-credentials",
                NAMESPACE,
                configmap_body,
                pretty="true",
                field_manager="ns1-bootstrap",
            )
            pprint(k8s_response)
        except ApiException as e:
            print(
                "Exception when calling CoreV1Api->replace_namespaced_config_map: %s\n"
                % e
            )

    except BootstrapError as e:
        fail("Exception catched: {}".format(e))


if __name__ == "__main__":
    main()
