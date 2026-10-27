# bar-like charts draw the same texts in the same order

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL      label rank_x rank_y
       axis-x    NA     1     Police      1     NA
       axis-x    NA     1     Courts      2     NA
       axis-x    NA     1 Parliament      3     NA
       axis-y    NA     1       100%     NA      1
       axis-y    NA     1        80%     NA      2
       axis-y    NA     1        60%     NA      3
       axis-y    NA     1        40%     NA      4
       axis-y    NA     1        20%     NA      5
       axis-y    NA     1         0%     NA      6
        layer     2     1        72%      1      1
        layer     2     1        64%      2      2
        layer     2     1        39%      3      3

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL    label rank_x rank_y
       axis-x    NA     1       0%      1     NA
       axis-x    NA     1      20%      2     NA
       axis-x    NA     1      40%      3     NA
       axis-x    NA     1      60%      4     NA
       axis-x    NA     1      80%      5     NA
       axis-x    NA     1     100%      6     NA
       axis-y    NA     1 Consumer     NA      1
       axis-y    NA     1  Housing     NA      2
        layer     3     1       7%      1      1
        layer     3     1      10%      2      1
        layer     3     1      21%      3      1
        layer     3     1      40%      4      1

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL label rank_x rank_y
       axis-x    NA     1  100%      1     NA
       axis-x    NA     1   75%      2     NA
       axis-x    NA     1   50%      3     NA
       axis-x    NA     1   25%      4     NA
       axis-x    NA     1    0%      5     NA
       axis-x    NA     1   25%      6     NA
       axis-x    NA     1   50%      7     NA
       axis-x    NA     1   75%      8     NA
       axis-x    NA     1  100%      9     NA
       axis-y    NA     1     A     NA      1
       axis-y    NA     1     B     NA      2
        layer     3     1   40%      3      1
        layer     3     1   30%      1      2
        layer     3     1   60%      3      3
        layer     3     1   70%      1      4

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL      label rank_x rank_y
       axis-y    NA     1          0     NA      1
       axis-y    NA     1         -1     NA      2
       axis-y    NA     1         -2     NA      3
       axis-y    NA     1         -3     NA      4
       axis-y    NA     1         -4     NA      5
        layer     2     1     Police      1      1
        layer     2     1     Courts      1      2
        layer     2     1 Parliament      1      3
        layer     3     1        72%      3      1
        layer     3     1        64%      2      2
        layer     3     1        39%      1      3

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL      label rank_x rank_y
       axis-x    NA     1         0%      1     NA
       axis-x    NA     1        20%      2     NA
       axis-x    NA     1        40%      3     NA
       axis-x    NA     1        60%      4     NA
       axis-x    NA     1        80%      5     NA
       axis-x    NA     1       100%      6     NA
       axis-y    NA     1     Police     NA      1
       axis-y    NA     1     Courts     NA      2
       axis-y    NA     1 Parliament     NA      3
        layer     3     1        72%      3      1
        layer     3     1        64%      2      2
        layer     3     1        39%      1      3

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL       label rank_x rank_y
        layer     3     1         61%      1      1
        layer     3     1         32%      1      2
        layer     3     1         28%      1      3
        layer     4     1 Information      1      1
        layer     4     1  Assistance      1      2
        layer     4     1  Resolution      1      3

# grouped bars keep their row order in both header modes

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL  label rank_x rank_y
       axis-x    NA     1      0      1     NA
       axis-x    NA     1     30      2     NA
       axis-x    NA     1     60      3     NA
       axis-x    NA     1     90      4     NA
       axis-x    NA     1     NA     NA     NA
       axis-x    NA     2      0      1     NA
       axis-x    NA     2     30      2     NA
       axis-x    NA     2     60      3     NA
       axis-x    NA     2     90      4     NA
       axis-x    NA     2     NA     NA     NA
       axis-y    NA     1  18-29     NA      1
       axis-y    NA     1  30-49     NA      2
       axis-y    NA     1    50+     NA      3
       axis-y    NA     2 Female     NA      1
       axis-y    NA     2   Male     NA      2
        layer     2     1    38%      1      1
        layer     2     1    55%      2      2
        layer     2     2    52%      2      1
        layer     2     2    45%      1      2
        strip    NA     1    Age     NA     NA
        strip    NA     2 Gender     NA     NA

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL            label rank_x rank_y
        layer     3     1              50%      1      1
        layer     3     1              42%      1      2
        layer     3     1              52%      1      3
        layer     3     1              45%      1      4
        layer     3     1              38%      1      5
        layer     3     1              N/A      1      6
        layer     3     1              55%      1      7
        layer     4     1 National Average      1      1
        layer     4     1       EU Average      1      2
        layer     4     1           Gender      1      3
        layer     4     1           Female      1      4
        layer     4     1             Male      1      5
        layer     4     1              Age      1      6
        layer     4     1            18-29      1      7
        layer     4     1            30-49      1      8
        layer     4     1              50+      1      9

# point and line charts draw the same texts in the same order

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL label rank_x rank_y
       axis-x    NA     1    0%      1     NA
       axis-x    NA     1   20%      2     NA
       axis-x    NA     1   40%      3     NA
       axis-x    NA     1   60%      4     NA
       axis-x    NA     1   80%      5     NA
       axis-x    NA     1  100%      6     NA
       axis-y    NA     1     A     NA      1
       axis-y    NA     1     B     NA      2

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL  label rank_x rank_y
       axis-x    NA     1     0%      1     NA
       axis-x    NA     1    20%      2     NA
       axis-x    NA     1    40%      3     NA
       axis-x    NA     1    60%      4     NA
       axis-x    NA     1    80%      5     NA
       axis-x    NA     1   100%      6     NA
       axis-y    NA     1 Courts     NA      1
       axis-y    NA     1 Police     NA      2
        layer     6     1    60%      1      1
        layer     6     1    45%      2      2
        layer     6     1    40%      2      3

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL  label rank_x rank_y
       axis-x    NA     1 2019.0      1     NA
       axis-x    NA     1 2019.5      2     NA
       axis-x    NA     1 2020.0      3     NA
       axis-x    NA     1 2020.5      4     NA
       axis-x    NA     1 2021.0      5     NA
       axis-y    NA     1   100%     NA      1
       axis-y    NA     1    80%     NA      2
       axis-y    NA     1    60%     NA      3
       axis-y    NA     1    40%     NA      4
       axis-y    NA     1    20%     NA      5
       axis-y    NA     1     0%     NA      6
        layer     3     1    60%      5      1
        layer     3     1    55%      3      2
        layer     3     1    50%      1      3
        layer     3     1    35%      5      4
        layer     3     1    25%      3      5
        layer     3     1    20%      1      6

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL label rank_x rank_y
       axis-x    NA     1  2019      1     NA
       axis-x    NA     1  2021      2     NA
       axis-y    NA     1  100%     NA      1
       axis-y    NA     1   80%     NA      2
       axis-y    NA     1   60%     NA      3
       axis-y    NA     1   40%     NA      4
       axis-y    NA     1   20%     NA      5
       axis-y    NA     1    0%     NA      6
        layer     3     1   60%      3      1
        layer     3     1   50%      1      2
        layer     3     1   35%      3      3
        layer     3     1   20%      1      4

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL    label rank_x rank_y
       axis-x    NA     1       10      1     NA
       axis-x    NA     1       20      2     NA
       axis-x    NA     1       30      3     NA
       axis-x    NA     1       40      4     NA
       axis-x    NA     2       10      1     NA
       axis-x    NA     2       20      2     NA
       axis-x    NA     2       30      3     NA
       axis-x    NA     2       40      4     NA
       axis-y    NA     1      6.0     NA      1
       axis-y    NA     1      5.5     NA      2
       axis-y    NA     1      5.0     NA      3
       axis-y    NA     1      4.5     NA      4
       axis-y    NA     1       NA     NA     NA
       axis-y    NA     2      6.0     NA      1
       axis-y    NA     2      5.5     NA      2
       axis-y    NA     2      5.0     NA      3
       axis-y    NA     2      4.5     NA      4
       axis-y    NA     2       NA     NA     NA
        layer     2     1 Consumer      1      1
        layer     2     2 Consumer      1      1
        strip    NA     1    Urban     NA     NA
        strip    NA     2    Rural     NA     NA

# radial and special charts draw the same texts in the same order

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL label rank_x rank_y
       axis-x    NA     1    -1      1     NA
       axis-x    NA     1     0      2     NA
       axis-x    NA     1     1      3     NA
       axis-x    NA     1    NA     NA     NA
       axis-x    NA     1    NA     NA     NA
       axis-y    NA     1     1     NA      1
       axis-y    NA     1     0     NA      2
       axis-y    NA     1    -1     NA      3
       axis-y    NA     1    NA     NA     NA
       axis-y    NA     1    NA     NA     NA
        layer     5     1  100%      1      1
        layer     5     1   80%      2      2
        layer     5     1   60%      3      3
        layer     5     1   40%      4      4
        layer     5     1   20%      5      5
        layer     5     1    0%      6      6
        layer     6     1     A      3      1
        layer     6     1     E      5      2
        layer     6     1     B      1      3
        layer     6     1     D      4      4
        layer     6     1     C      2      5

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL label rank_x rank_y
        layer     4     1     A      1      1
        layer     4     1     B      2      1
        layer     4     1     E      3      1
        layer     4     1     C      4      1
        layer     4     1     D      5      1

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL label rank_x rank_y
        layer     2     1   40%      1      1
        layer     2     1   35%      1      2
        layer     2     1   25%      1      3

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL           label rank_x rank_y
        layer     2     1             30%      1      1
        layer     2     1             40%      3      1
        layer     2     1             26%      1      3
        layer     2     1             36%      3      3
        layer     3     1       −4 points      1      1
        layer     3     1       −4 points      2      1
        layer     4     1        Resolved      1      1
        layer     4     1    Not resolved      2      1
        layer     5     1   Health issues      1      1
        layer     5     1 Economic issues      1      2

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL label rank_x rank_y
       axis-x    NA     1     A      1     NA
       axis-x    NA     1     B      2     NA
       axis-y    NA     1     A     NA      1
       axis-y    NA     1     B     NA      2
        layer     2     1   10%      1      1
        layer     2     1   60%      3      1
        layer     2     1   55%      1      3
        layer     2     1   12%      3      3

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL            label rank_x rank_y
        layer     3     1   Family\\n(18%)      2      1
        layer     3     1 Consumer\\n(40%)      1      2
        layer     3     1  Housing\\n(10%)      3      2

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL       label rank_x rank_y
        layer     7     1 Information      1      1
        layer     7     1  Assistance      1      2
        layer     8     1         17%      1      1
        layer     8     1         12%      3      2
        layer     8     1          8%      2      3

---

    Code
      print(drawn_signature(p), row.names = FALSE)
    Output
       source layer PANEL     label rank_x rank_y
        layer     4     1      good      3      1
        layer     4     1    access      6      1
        layer     4     1       yes      1      3
        layer     4     1      none      3      4
        layer     4     1 no_access      6      4
        layer     4     1        no      1      6
        layer     4     1      skip      3      7
        layer     4     1  excluded      6      7
        layer     5     1       30%      3      1
        layer     5     1       30%      6      1
        layer     5     1       30%      1      3
        layer     5     1       40%      3      4
        layer     5     1       40%      6      4
        layer     5     1       70%      1      6
        layer     5     1       30%      3      7
        layer     5     1       30%      6      7

