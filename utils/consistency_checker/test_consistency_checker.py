import unittest
import asyncio
import consistency_checker
from consistency_checker import *
import async_distribution
import full_async_checker

KEY_PARAMS = ["answers", "ans_count", "ttl", "rcode", "flags"]


class AutoTTestTestCase(unittest.TestCase):
    """
    Tests for consistency_checker.py
    """

    def test_read_records_file_normal_case(self):
        """
        Tests the functionality of the records file reader for normal
        functionality (file as expected)
        """
        normal_file = "unit_tests\\record_files\\records1.csv"
        expected = [
            ("frazao.ca", "A"),
            ("not-pulsar.frazao.ca", "A"),
            ("kitkatonline.com", "A"),
            ("dropbox.com", "A"),
            ("yelp.com", "A"),
        ]
        self.assertEqual(
            list(read_records_file(normal_file)), expected, msg="return_list=False"
        )

    def test_read_records_file_duplicate_records(self):
        """
        Tests the functionality of the records file reader when the list
        contains duplicates
        """
        duplicate_file = "unit_tests\\record_files\\records2.csv"
        expected = [
            ("frazao.ca", "A"),
            ("not-pulsar.frazao.ca", "A"),
            ("kitkatonline.com", "A"),
            ("dropbox.com", "A"),
            ("yelp.com", "A"),
        ] * 4
        self.assertEqual(
            list(read_records_file(duplicate_file)), expected, msg="return_list=False"
        )

    def test_read_records_file_blank_file(self):
        """
        Tests the functionality of the records file reader when the list is
        completely blank
        """
        blank_file = "unit_tests\\record_files\\records3.csv"
        expected = []
        self.assertEqual(
            list(read_records_file(blank_file)), expected, msg="return_list=False"
        )

    def test_make_dns_query_normal(self):
        """
        Test the querying function for normal functionality by comparing the
        result of the query against a known IP
        """
        expected = {
            "answers": ["198.51.44.1"],
            "ans_count": 1,
            "ttl": 86400,
            "rcode": 0,
            "query_time": 1,
            "flags": 34048,
        }
        server = dns.resolver.Resolver(configure=False)
        server.nameservers = ["198.51.44.1"]
        domain = "dns1.p01.nsone.net"
        rec_type = "A"

        result = make_dns_query(domain, rec_type, server)
        for param in KEY_PARAMS:
            self.assertEqual(result[param], expected[param], msg=f"Parameter: {param}")

    def test_async_make_dns_query(self):
        """
        Test the async querying function by comparing the result of the query
        against a known IP
        """
        expected = {
            "answers": ["198.51.44.1"],
            "ans_count": 1,
            "ttl": 86400,
            "rcode": 0,
            "query_time": 1,
            "flags": None,
        }
        server = ["198.51.44.1"]
        domain = "dns1.p01.nsone.net"
        rec_type = "A"
        task = full_async_checker.dns_coroutine(domain, rec_type, server)
        loop = asyncio.get_event_loop()
        result = loop.run_until_complete(asyncio.gather(task))[0]

        for param in KEY_PARAMS:
            self.assertEqual(result[param], expected[param], msg=f"Parameter: {param}")

    def test_diff_check(self):
        answers = {
            "control": {
                "answers": ["1.1.1.1"],
                "ans_count": 1,
                "ttl": 3600,
                "rcode": 0,
                "query_time": 1.0,
                "flags": 33212,
            },
            "target": {
                "answers": ["1.1.1.1"],
                "ans_count": 1,
                "ttl": 3600,
                "rcode": 0,
                "query_time": 1.0,
                "flags": 33212,
            },
        }
        self.assertIsNone(diff_check(answers), msg="matching answers")
        for param in KEY_PARAMS:
            temp = answers["target"][param]
            answers["target"][param] = 666
            with self.assertRaises(
                ResponseDifference, msg=f"non-matching answers - parameter: {param}"
            ):
                diff_check(answers)
            answers["target"][param] = temp

    def test_get_distribution(self):
        domain = "dns1.p01.nsone.net"
        record_type = "A"
        expected = {"control": {"198.51.44.1": 25}, "target": {"198.51.44.1": 25}}
        control = dns.resolver.Resolver(configure=False)
        control.nameservers = ["8.8.8.8"]

        target = dns.resolver.Resolver(configure=False)
        target.nameservers = ["1.1.1.1"]

        servers = {"control": control, "target": target}

        consistency_checker.NUM_TRIALS = 25
        self.assertEqual(get_distribution(domain, record_type, servers), expected)

    def test_async_get_distribution(self):
        domain = "dns1.p01.nsone.net"
        record_type = "A"
        expected = {"control": {"198.51.44.1": 50}, "target": {"198.51.44.1": 50}}
        control = ["8.8.8.8"]
        target = ["1.1.1.1"]

        servers = {"control": control, "target": target}

        self.assertEqual(
            async_distribution.get_distribution(domain, record_type, servers, 50),
            expected,
        )

    def test_distribution_diff_check_matching(self):
        """
        Test the distribution_diff_check function for various distributions
        """
        # No difference (exact)
        d1 = {
            "control": {"1.1.1.1": 500, "2.2.2.2": 500},
            "target": {"1.1.1.1": 500, "2.2.2.2": 500},
        }
        # Not statistically different (inexact match)
        d2 = {
            "control": {"1.1.1.1": 488, "2.2.2.2": 512},
            "target": {"1.1.1.1": 512, "2.2.2.2": 488},
        }
        # Statistically different distributions
        d3 = {
            "control": {"1.1.1.1": 488, "2.2.2.2": 512},
            "target": {"1.1.1.1": 700, "2.2.2.2": 300},
        }

        self.assertIsNotNone(distribution_diff_check(d1))
        self.assertIsNotNone(distribution_diff_check(d2))
        with self.assertRaises(ResponseDifference):
            distribution_diff_check(d3)


if __name__ == "__main__":
    unittest.main()
