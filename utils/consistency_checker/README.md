# DNS Consistency Checker

## Objective

Script aims to automate the testing for response differences in different DNS servers and flag major differences for manual review.

## Requirements

- Python 3.6 or higher
- dnspython `pip install dnspython`
- async_dns: `pip install async_dns`

## Main Operation

1. Parse Inputs
2. Iterate over list of DNS records and make DNS queries for each record to both the control and target DNS servers
3. Flag records with potential differences in results for further manual review

From the command line use the -h flag to show all options and commands available. For basic operation you should designate an input file with the records to be tested, the file for the results to be written in, the IP address of the control server, the IP address of the target server, and optionally you may designate a mode of operation (single threaded, multi-threaded, or async).

Example:

```text
$ python consistency_checker.py -c 123.123.123.123 -t 234.234.234.234 -r input.csv -f output.csv -a
Warning - discrepancy found for geoweighted.example.com_CNAME
Nominal results for geoweighted.wtfcat.org_CNAME Chi square value of 3.4 is less than statistical threshold of 9.21:
______________________Answer______________________|_Control__|__Target__|
................a.east.example.com................|...2284...|...2258...|
................b.east.example.com................|...216....|...242....|
```

Any differences are identified in the console and the results are written to the file specified in the output argument.

## Pain Points in Previous Solutions

Previous iterations of difference checking scripts used required a lot of manual review in order to determine if a change was meaningful or not. The biggest flaw / pain point in the past was reviewing records with non-deterministic behavior (e.g., round robin DNS) to assess whether the behavior is expected or represented an actual change.

## Handling Non-Deterministic Behavior

We can deal with records that are inherently non-deterministic, such as round robin DNS, by querying the record enough times to develop a distribution of the results and comparing the distribution of the control vs the target nameserver. For example given the following record:

Zone: example.com
Domain: shuffle.example.com
Type: A
Answers:

- 1.1.1.1
- 2.2.2.2
- 3.3.3.3
- 4.4.4.4

Example DIG:

```text
$ dig shuffle.example.com +short
1.1.1.1
$ dig shuffle.example.com +short
3.3.3.3
```

|Answer|Expected Distribution|Actual Distribution|
|-------|--------------------|-------------------|
|1.1.1.1| 25%| 26%|
|2.2.2.2| 25%| 23%|
|3.3.3.3| 25%| 25%|
|4.4.4.4| 25%| 25%|

We would expect there to be a 1/4 chance of any one answer being served. This distribution should remain the same at both the control and target nameservers. Doing a single query and simply doing a diff on the results has a 3/4 (75%) chance of resulting in a false positive and being flagged for human review when that might not be necessary. This phenomenon (false positives) occurring over hundreds or thousands of records makes testing essentially like looking for a needle in a haystack due to all the false positives.

In order to determine whether two distributions are the same we will use the Pearson chi-square statistic (as described in: <https://www3.nd.edu/~rwilliam/stats1/x51.pdf>)

For our test:
H0 (null hypothesis): There has been no change across time. The distribution of DNS answers in the target server is the same as the distribution of DNS answers in the control servers.

HA: There has been change across the servers. The target answer distribution differs from the answer distribution of the control server.

The Pearson chi-square statistic: <a href="https://www.codecogs.com/eqnedit.php?latex=\chi^2_{c-1}&space;=&space;\sum{(O_j&space;-&space;E_j)^2/E_j}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\chi^2_{c-1}&space;=&space;\sum{(O_j&space;-&space;E_j)^2/E_j}" title="\chi^2_{c-1} = \sum{(O_j - E_j)^2/E_j}" /></a>

Where:

- $O_j$ is the observed frequency for an answer in the target server
- $E_j$ is the expected frequency for an answer in the target server (i.e., the control frequency)

Smaller values of chi squared represent closer fit of the expected and observed frequencies.

We accept H0 if our statistic $\chi^2$ is less than the tabled value at the given confidence level (look at table below)

From: <https://www.itl.nist.gov/div898/handbook/eda/section3/eda3674.htm>

```text
Upper-tail critical values of chi-square distribution with ν degrees of freedom

                Probability less than the critical value
  ν           0.90      0.95     0.975      0.99     0.999

  1          2.706     3.841     5.024     6.635    10.828
  2          4.605     5.991     7.378     9.210    13.816
  3          6.251     7.815     9.348    11.345    16.266
  4          7.779     9.488    11.143    13.277    18.467
  5          9.236    11.070    12.833    15.086    20.515
  6         10.645    12.592    14.449    16.812    22.458
  7         12.017    14.067    16.013    18.475    24.322
  8         13.362    15.507    17.535    20.090    26.125
  9         14.684    16.919    19.023    21.666    27.877
 10         15.987    18.307    20.483    23.209    29.588
 11         17.275    19.675    21.920    24.725    31.264
 12         18.549    21.026    23.337    26.217    32.910
 13         19.812    22.362    24.736    27.688    34.528
 14         21.064    23.685    26.119    29.141    36.123
 15         22.307    24.996    27.488    30.578    37.697
 16         23.542    26.296    28.845    32.000    39.252
 17         24.769    27.587    30.191    33.409    40.790
 18         25.989    28.869    31.526    34.805    42.312
 19         27.204    30.144    32.852    36.191    43.820
 20         28.412    31.410    34.170    37.566    45.315
 21         29.615    32.671    35.479    38.932    46.797
 22         30.813    33.924    36.781    40.289    48.268
 23         32.007    35.172    38.076    41.638    49.728
 24         33.196    36.415    39.364    42.980    51.179
 25         34.382    37.652    40.646    44.314    52.620
 26         35.563    38.885    41.923    45.642    54.052
 27         36.741    40.113    43.195    46.963    55.476
 28         37.916    41.337    44.461    48.278    56.892
 29         39.087    42.557    45.722    49.588    58.301
 30         40.256    43.773    46.979    50.892    59.703
 31         41.422    44.985    48.232    52.191    61.098
 32         42.585    46.194    49.480    53.486    62.487
 33         43.745    47.400    50.725    54.776    63.870
 34         44.903    48.602    51.966    56.061    65.247
 35         46.059    49.802    53.203    57.342    66.619
 36         47.212    50.998    54.437    58.619    67.985
 37         48.363    52.192    55.668    59.893    69.347
 38         49.513    53.384    56.896    61.162    70.703
 39         50.660    54.572    58.120    62.428    72.055
 40         51.805    55.758    59.342    63.691    73.402
 41         52.949    56.942    60.561    64.950    74.745
 42         54.090    58.124    61.777    66.206    76.084
 43         55.230    59.304    62.990    67.459    77.419
 44         56.369    60.481    64.201    68.710    78.750
 45         57.505    61.656    65.410    69.957    80.077
 46         58.641    62.830    66.617    71.201    81.400
 47         59.774    64.001    67.821    72.443    82.720
 48         60.907    65.171    69.023    73.683    84.037
 49         62.038    66.339    70.222    74.919    85.351
 50         63.167    67.505    71.420    76.154    86.661
 51         64.295    68.669    72.616    77.386    87.968
 52         65.422    69.832    73.810    78.616    89.272
 53         66.548    70.993    75.002    79.843    90.573
 54         67.673    72.153    76.192    81.069    91.872
 55         68.796    73.311    77.380    82.292    93.168
 56         69.919    74.468    78.567    83.513    94.461
 57         71.040    75.624    79.752    84.733    95.751
 58         72.160    76.778    80.936    85.950    97.039
 59         73.279    77.931    82.117    87.166    98.324
 60         74.397    79.082    83.298    88.379    99.607
 61         75.514    80.232    84.476    89.591   100.888
 62         76.630    81.381    85.654    90.802   102.166
 63         77.745    82.529    86.830    92.010   103.442
 64         78.860    83.675    88.004    93.217   104.716
 65         79.973    84.821    89.177    94.422   105.988
 66         81.085    85.965    90.349    95.626   107.258
 67         82.197    87.108    91.519    96.828   108.526
 68         83.308    88.250    92.689    98.028   109.791
 69         84.418    89.391    93.856    99.228   111.055
 70         85.527    90.531    95.023   100.425   112.317
 71         86.635    91.670    96.189   101.621   113.577
 72         87.743    92.808    97.353   102.816   114.835
 73         88.850    93.945    98.516   104.010   116.092
 74         89.956    95.081    99.678   105.202   117.346
 75         91.061    96.217   100.839   106.393   118.599
 76         92.166    97.351   101.999   107.583   119.850
 77         93.270    98.484   103.158   108.771   121.100
 78         94.374    99.617   104.316   109.958   122.348
 79         95.476   100.749   105.473   111.144   123.594
 80         96.578   101.879   106.629   112.329   124.839
 81         97.680   103.010   107.783   113.512   126.083
 82         98.780   104.139   108.937   114.695   127.324
 83         99.880   105.267   110.090   115.876   128.565
 84        100.980   106.395   111.242   117.057   129.804
 85        102.079   107.522   112.393   118.236   131.041
 86        103.177   108.648   113.544   119.414   132.277
 87        104.275   109.773   114.693   120.591   133.512
 88        105.372   110.898   115.841   121.767   134.746
 89        106.469   112.022   116.989   122.942   135.978
 90        107.565   113.145   118.136   124.116   137.208
 91        108.661   114.268   119.282   125.289   138.438
 92        109.756   115.390   120.427   126.462   139.666
 93        110.850   116.511   121.571   127.633   140.893
 94        111.944   117.632   122.715   128.803   142.119
 95        113.038   118.752   123.858   129.973   143.344
 96        114.131   119.871   125.000   131.141   144.567
 97        115.223   120.990   126.141   132.309   145.789
 98        116.315   122.108   127.282   133.476   147.010
 99        117.407   123.225   128.422   134.642   148.230
100        118.498   124.342   129.561   135.807   149.449
100        118.498   124.342   129.561   135.807   149.449
```

Known Non-Deterministic Record Types (NS1 Filter Chains):

- Shuffle (round robin DNS)
- Weighted Shuffle (round robin DNS where some answers are weighted / preferred)
- Sticky Shuffle (a given IP address will always correspond to an answer given a static answer list)
- Load Shed (once server load has exceeded a set low watermark the answer being served may change)

## Input File

This program accepts the list of records as a CSV format file. The input file should be a CSV with each line representing a domain followed by the record type. For example:

```text
example.com,A
www.example.com,A
foo.com,A
bar.com,A
foobar.com,A
```

## Output

### Console

As the program runs it will display on the console any differences that it identifies. It will also follow up confirming whether or not the distribution test shows a difference. For example:

```text
Warning - discrepancy found for geoweighted.example.com_CNAME
Nominal results for geoweighted.wtfcat.org_CNAME Chi square value of 3.4 is less than statistical threshold of 9.21:
______________________Answer______________________|_Control__|__Target__|
................a.east.example.com................|...2284...|...2258...|
................b.east.example.com................|...216....|...242....|
```

Where an originally identified difference in geoweighted.example.com_CNAME is shown to actually be ok when the distribution is tested.

### File

This program outputs a list of differences in a CSV format. In case the program identifies any differences in answer distributions it will write the answer distributions to the CSV file. If no differences are identified it will write a file containing only the headers with no more information below it.

```csv
Record,Information
foo.com_A,{'control': {'1.1.1.1': 83, '2.2.2.2': 17}, 'target': {'1.1.1.1': 55, '2.2.2.2': 45}}
bar.foo.com_CNAME,{'control': {'foo.com': 95, 'b.foo.com': 5}, 'target': {'foo.com': 52, 'b.foo.com': 48}
```

## Modes of Operations

This program has options to run in three modes of operations: single threaded, multi threaded, or async. Approximate performances given below are **highly dependent on the computer, set of records, and the control & target servers** and will vary greatly from instance to instance. Consider toggling between different modes of operation if you run the risk of being rate limited by your control or target servers. Otherwise my recommendation is to always run it in the fastest mode available (full async) with the `-a` flag set. 

### Single threaded

Activated with the `-s` flag on the command line. Approximate performance ~10 QPS

### Multi threaded

Activated with the `-m` flag on the command line. Approximate performance ~100QPS

### Partial Async

The default mode of operation if no flag is designated. Approximate performance ~200QPS. Pure performance benchmarking of the DNS querying by itself shows a performance of ~1200+ QPS.

### Full Async

Activated with the `-a` flag on the command line. Approximate performance >300QPS (have observed up to 1200QPS in test runs).
