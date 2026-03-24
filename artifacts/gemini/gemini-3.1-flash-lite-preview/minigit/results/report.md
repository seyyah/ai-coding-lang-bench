# AI Coding Language Benchmark Report

## Environment
- Date: 2026-03-15 19:45:38
- Codex filter: gemini
- Problem: minigit
- Codex version: gemini-3.1-flash-lite-preview
- Trials per language: 3
- Records in report: 45

## Language Versions
| Language | Version |
|----------|---------|
| Rust | rustc 1.75.0 (82e1608df 2023-12-21) (built from a source tarball) |
| Go | go version go1.22.2 linux/amd64 |
| C | gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0 |
| Typescript | tsx v4.21.0 |
| Javascript | v24.14.0 |
| Java | openjdk 21.0.10 2026-01-20 |
| Perl | This is perl 5, version 38, subversion 2 (v5.38.2) built for x86_64-linux-gnu-thread-multi |
| Python/mypy | Python 3.12.3 |
| Ruby | ruby 3.2.3 (2024-01-18 revision 52bb2ac0a6) [x86_64-linux-gnu] |
| Ruby/steep | ruby 3.2.3 (2024-01-18 revision 52bb2ac0a6) [x86_64-linux-gnu] |
| Lua | Lua 5.4.6  Copyright (C) 1994-2023 Lua.org, PUC-Rio |
| Scheme | guile (GNU Guile) 3.0.9 |
| Ocaml | The OCaml toplevel, version 4.14.1 |
| Haskell | The Glorious Glasgow Haskell Compilation System, version 9.4.7 |
| Python | Python 3.12.3 |

## Results Summary
| Language | v1 Time | v1 Turns | v1 LOC | v1 Tests | v2 Time | v2 Turns | v2 LOC | v2 Tests | Total Time | Avg Cost |
|----------|---------|----------|--------|----------|---------|----------|--------|----------|------------|----------|
| Rust | 4.1s±0.7s | 1.0 | 73 | 0/3 | 4.0s±0.7s | 1.0 | 95 | 0/3 | 8.1s±0.8s | $0.00 |
| Go | 19.0s±27.2s | 1.0 | 43 | 0/3 | 28.0s±41.7s | 1.0 | 57 | 0/3 | 47.0s±37.0s | $0.00 |
| C | 9.2s±8.6s | 1.0 | 62 | 0/3 | 3.9s±0.4s | 1.0 | 55 | 0/3 | 13.1s±8.2s | $0.00 |
| Typescript | 3.8s±0.2s | 1.0 | 56 | 0/3 | 4.8s±1.9s | 1.0 | 25 | 0/3 | 8.7s±1.9s | $0.00 |
| Javascript | 5.8s±4.7s | 1.0 | 28 | 0/3 | 3.7s±0.6s | 1.0 | 26 | 0/3 | 9.5s±4.1s | $0.00 |
| Java | 3.4s±0.4s | 1.0 | 58 | 0/3 | 4.2s±1.4s | 1.0 | 58 | 0/3 | 7.5s±1.1s | $0.00 |
| Perl | 5.7s±3.6s | 1.0 | 27 | 0/3 | 16.5s±22.5s | 1.0 | 28 | 0/3 | 22.2s±21.6s | $0.00 |
| Python/mypy | 6.4s±3.7s | 1.0 | 54 | 0/3 | 13.4s±15.6s | 1.0 | 89 | 0/3 | 19.8s±13.8s | $0.00 |
| Ruby | 14.9s±19.3s | 1.0 | 11 | 0/3 | 4.9s±1.2s | 1.0 | 44 | 0/3 | 19.8s±18.4s | $0.00 |
| Ruby/steep | 3.8s±0.5s | 1.0 | 38 | 0/3 | 5.0s±1.4s | 1.0 | 77 | 0/3 | 8.7s±1.0s | $0.00 |
| Lua | 4.2s±0.6s | 1.0 | 26 | 0/3 | 3.8s±0.3s | 1.0 | 21 | 0/3 | 8.0s±0.7s | $0.00 |
| Scheme | 4.1s±1.2s | 1.0 | 65 | 0/3 | 4.3s±0.6s | 1.0 | 37 | 0/3 | 8.4s±1.5s | $0.00 |
| Ocaml | 14.2s±18.3s | 1.0 | 90 | 0/3 | 4.5s±0.2s | 1.0 | 88 | 0/3 | 18.7s±18.1s | $0.00 |
| Haskell | 3.7s±0.8s | 1.0 | 54 | 0/3 | 5.3s±0.6s | 1.0 | 55 | 0/3 | 9.0s±0.2s | $0.00 |
| Python | 3.9s±0.5s | 1.0 | 30 | 0/3 | 4.1s±0.3s | 1.0 | 11 | 0/3 | 8.0s±0.6s | $0.00 |

## Token Summary
| Language | Avg Input | Avg Output | Avg Cache Create | Avg Cache Read | Avg Total | Avg Cost |
|----------|-----------|------------|------------------|----------------|-----------|----------|
| Rust | 114 | 1,709 | 0 | 0 | 1,823 | $0.0026 |
| Go | 114 | 1,459 | 0 | 0 | 1,573 | $0.0022 |
| C | 114 | 1,707 | 0 | 0 | 1,821 | $0.0026 |
| Typescript | 115 | 1,714 | 0 | 0 | 1,829 | $0.0026 |
| Javascript | 114 | 1,504 | 0 | 0 | 1,618 | $0.0023 |
| Java | 114 | 1,486 | 0 | 0 | 1,600 | $0.0023 |
| Perl | 114 | 1,600 | 0 | 0 | 1,714 | $0.0024 |
| Python/mypy | 187 | 1,951 | 0 | 0 | 2,138 | $0.0030 |
| Ruby | 114 | 1,696 | 0 | 0 | 1,810 | $0.0026 |
| Ruby/steep | 183 | 1,650 | 0 | 0 | 1,833 | $0.0025 |
| Lua | 114 | 1,660 | 0 | 0 | 1,774 | $0.0025 |
| Scheme | 114 | 1,701 | 0 | 0 | 1,815 | $0.0026 |
| Ocaml | 116 | 1,708 | 0 | 0 | 1,824 | $0.0026 |
| Haskell | 114 | 1,700 | 0 | 0 | 1,814 | $0.0026 |
| Python | 114 | 1,701 | 0 | 0 | 1,815 | $0.0026 |

## Full Results
| Codex | Language | Trial | v1 Time | v1 Turns | v1 LOC | v1 Tests | v2 Time | v2 Turns | v2 LOC | v2 Tests | Total Time | Cost |
|-------|----------|-------|---------|----------|--------|----------|---------|----------|--------|----------|------------|------|
| gemini | Rust | 1 | 3.8s | 1 | 76 | 0/5 FAIL | 4.8s | 1 | 144 | 0/7 FAIL | 8.6s | $0.00 |
| gemini | Go | 1 | 3.3s | 1 | 41 | 0/5 FAIL | 76.1s | 1 | 30 | 0/5 FAIL | 79.4s | $0.00 |
| gemini | C | 1 | 4.5s | 1 | 74 | 1/11 FAIL | 4.1s | 1 | 69 | 6/30 FAIL | 8.6s | $0.00 |
| gemini | Typescript | 1 | 4.0s | 1 | 98 | 2/11 FAIL | 3.7s | 1 | 26 | 0/5 FAIL | 7.7s | $0.00 |
| gemini | Javascript | 1 | 3.3s | 1 | 1 | 0/5 FAIL | 4.1s | 1 | 41 | 0/7 FAIL | 7.4s | $0.00 |
| gemini | Java | 1 | 3.7s | 1 | 67 | 0/5 FAIL | 3.6s | 1 | 47 | 1/5 FAIL | 7.3s | $0.00 |
| gemini | Perl | 1 | 4.3s | 1 | 45 | 0/5 FAIL | 42.5s | 1 | 44 | 5/30 FAIL | 46.8s | $0.00 |
| gemini | Python/mypy | 1 | 4.1s | 1 | 59 | 1/11 FAIL | 31.4s | 1 | 117 | 5/30 FAIL | 35.5s | $0.00 |
| gemini | Ruby | 1 | 3.6s | 1 | 1 | 0/5 FAIL | 4.6s | 1 | 43 | 0/5 FAIL | 8.2s | $0.00 |
| gemini | Ruby/steep | 1 | 3.9s | 1 | 44 | 2/11 FAIL | 5.7s | 1 | 79 | 0/5 FAIL | 9.6s | $0.00 |
| gemini | Lua | 1 | 3.9s | 1 | 1 | 0/5 FAIL | 4.1s | 1 | 33 | 0/5 FAIL | 8.0s | $0.00 |
| gemini | Scheme | 1 | 3.2s | 1 | 64 | 0/5 FAIL | 3.6s | 1 | 58 | 0/5 FAIL | 6.8s | $0.00 |
| gemini | Ocaml | 1 | 35.3s | 1 | 80 | 0/5 FAIL | 4.3s | 1 | 62 | 0/5 FAIL | 39.6s | $0.00 |
| gemini | Haskell | 1 | 3.6s | 1 | 56 | 0/5 FAIL | 5.4s | 1 | 47 | 0/5 FAIL | 9.0s | $0.00 |
| gemini | Rust | 2 | 4.9s | 1 | 77 | 0/5 FAIL | 3.6s | 1 | 78 | 0/5 FAIL | 8.5s | $0.00 |
| gemini | Go | 2 | 3.3s | 1 | 58 | 0/5 FAIL | 3.4s | 1 | 77 | 0/5 FAIL | 6.7s | $0.00 |
| gemini | C | 2 | 4.0s | 1 | 37 | 1/5 FAIL | 4.2s | 1 | 43 | 0/5 FAIL | 8.2s | $0.00 |
| gemini | Typescript | 2 | 3.7s | 1 | 43 | 0/5 FAIL | 3.8s | 1 | 25 | 0/5 FAIL | 7.5s | $0.00 |
| gemini | Javascript | 2 | 2.9s | 1 | 37 | 0/6 FAIL | 4.0s | 1 | 35 | 5/30 FAIL | 6.9s | $0.00 |
| gemini | Java | 2 | 3.5s | 1 | 72 | 0/5 FAIL | 3.1s | 1 | 68 | 0/5 FAIL | 6.6s | $0.00 |
| gemini | Perl | 2 | 3.0s | 1 | 1 | 0/5 FAIL | 3.5s | 1 | 8 | 0/5 FAIL | 6.5s | $0.00 |
| gemini | Python | 2 | 3.6s | 1 | 4 | 0/5 FAIL | 4.4s | 1 | 1 | 0/5 FAIL | 8.0s | $0.00 |
| gemini | Python/mypy | 2 | 4.4s | 1 | 48 | 1/5 FAIL | 5.0s | 1 | 53 | 0/5 FAIL | 9.4s | $0.00 |
| gemini | Ruby | 2 | 37.2s | 1 | 1 | 0/5 FAIL | 3.8s | 1 | 36 | 0/5 FAIL | 41.0s | $0.00 |
| gemini | Ruby/steep | 2 | 4.2s | 1 | 26 | 0/5 FAIL | 3.4s | 1 | 60 | 0/5 FAIL | 7.6s | $0.00 |
| gemini | Lua | 2 | 3.8s | 1 | 41 | 0/5 FAIL | 3.5s | 1 | 1 | 0/5 FAIL | 7.3s | $0.00 |
| gemini | Scheme | 2 | 5.4s | 1 | 58 | 0/5 FAIL | 4.4s | 1 | 18 | 0/5 FAIL | 9.8s | $0.00 |
| gemini | Ocaml | 2 | 3.4s | 1 | 62 | 1/5 FAIL | 4.7s | 1 | 64 | 1/5 FAIL | 8.1s | $0.00 |
| gemini | Haskell | 2 | 3.0s | 1 | 56 | 0/5 FAIL | 5.8s | 1 | 85 | 0/5 FAIL | 8.8s | $0.00 |
| gemini | Rust | 3 | 3.6s | 1 | 66 | 0/5 FAIL | 3.6s | 1 | 62 | 0/5 FAIL | 7.2s | $0.00 |
| gemini | Go | 3 | 50.4s | 1 | 31 | 0/5 FAIL | 4.4s | 1 | 64 | 0/5 FAIL | 54.8s | $0.00 |
| gemini | C | 3 | 19.1s | 1 | 74 | 0/5 FAIL | 3.5s | 1 | 52 | 0/5 FAIL | 22.6s | $0.00 |
| gemini | Typescript | 3 | 3.8s | 1 | 28 | 0/5 FAIL | 7.0s | 1 | 23 | 0/5 FAIL | 10.8s | $0.00 |
| gemini | Javascript | 3 | 11.2s | 1 | 47 | 0/5 FAIL | 3.0s | 1 | 1 | 0/5 FAIL | 14.2s | $0.00 |
| gemini | Java | 3 | 2.9s | 1 | 35 | 0/5 FAIL | 5.8s | 1 | 60 | 0/5 FAIL | 8.7s | $0.00 |
| gemini | Perl | 3 | 9.7s | 1 | 36 | 0/5 FAIL | 3.6s | 1 | 33 | 0/5 FAIL | 13.3s | $0.00 |
| gemini | Python | 3 | 4.5s | 1 | 50 | 0/5 FAIL | 4.0s | 1 | 31 | 0/5 FAIL | 8.5s | $0.00 |
| gemini | Python/mypy | 3 | 10.6s | 1 | 55 | 2/11 FAIL | 3.9s | 1 | 97 | 0/5 FAIL | 14.5s | $0.00 |
| gemini | Ruby | 3 | 3.9s | 1 | 32 | 0/11 FAIL | 6.2s | 1 | 52 | 0/5 FAIL | 10.1s | $0.00 |
| gemini | Ruby/steep | 3 | 3.2s | 1 | 43 | 0/5 FAIL | 5.8s | 1 | 93 | 0/5 FAIL | 9.0s | $0.00 |
| gemini | Lua | 3 | 4.9s | 1 | 36 | 0/5 FAIL | 3.8s | 1 | 29 | 0/5 FAIL | 8.7s | $0.00 |
| gemini | Scheme | 3 | 3.7s | 1 | 74 | 0/5 FAIL | 4.8s | 1 | 34 | 0/5 FAIL | 8.5s | $0.00 |
| gemini | Ocaml | 3 | 3.9s | 1 | 129 | 0/5 FAIL | 4.5s | 1 | 138 | 5/30 FAIL | 8.4s | $0.00 |
| gemini | Haskell | 3 | 4.5s | 1 | 51 | 3/11 FAIL | 4.7s | 1 | 34 | 0/5 FAIL | 9.2s | $0.00 |
| gemini | Python | 1 | 3.6s | 1 | 36 | 1/11 FAIL | 3.8s | 1 | 1 | 0/5 FAIL | 7.4s | $0.00 |

## Full Tokens
| Codex | Language | Trial | Phase | Input | Output | Cache Create | Cache Read | Total | Cost USD |
|-------|----------|-------|-------|-------|--------|--------------|------------|-------|----------|
| gemini | Rust | 1 | v1 | 78 | 818 | 0 | 0 | 896 | $0.0012 |
| gemini | Rust | 1 | v2 | 36 | 1,040 | 0 | 0 | 1,076 | $0.0016 |
| gemini | Go | 1 | v1 | 78 | 713 | 0 | 0 | 791 | $0.0011 |
| gemini | Go | 1 | v2 | 36 | 781 | 0 | 0 | 817 | $0.0012 |
| gemini | C | 1 | v1 | 78 | 747 | 0 | 0 | 825 | $0.0011 |
| gemini | C | 1 | v2 | 36 | 900 | 0 | 0 | 936 | $0.0014 |
| gemini | Typescript | 1 | v1 | 79 | 986 | 0 | 0 | 1,065 | $0.0015 |
| gemini | Typescript | 1 | v2 | 36 | 735 | 0 | 0 | 771 | $0.0011 |
| gemini | Javascript | 1 | v1 | 78 | 734 | 0 | 0 | 812 | $0.0011 |
| gemini | Javascript | 1 | v2 | 36 | 739 | 0 | 0 | 775 | $0.0011 |
| gemini | Java | 1 | v1 | 78 | 846 | 0 | 0 | 924 | $0.0013 |
| gemini | Java | 1 | v2 | 36 | 712 | 0 | 0 | 748 | $0.0011 |
| gemini | Perl | 1 | v1 | 78 | 930 | 0 | 0 | 1,008 | $0.0014 |
| gemini | Perl | 1 | v2 | 36 | 792 | 0 | 0 | 828 | $0.0012 |
| gemini | Python/mypy | 1 | v1 | 116 | 1,032 | 0 | 0 | 1,148 | $0.0016 |
| gemini | Python/mypy | 1 | v2 | 71 | 1,016 | 0 | 0 | 1,087 | $0.0015 |
| gemini | Ruby | 1 | v1 | 78 | 867 | 0 | 0 | 945 | $0.0013 |
| gemini | Ruby | 1 | v2 | 36 | 846 | 0 | 0 | 882 | $0.0013 |
| gemini | Ruby/steep | 1 | v1 | 114 | 856 | 0 | 0 | 970 | $0.0013 |
| gemini | Ruby/steep | 1 | v2 | 69 | 792 | 0 | 0 | 861 | $0.0012 |
| gemini | Lua | 1 | v1 | 78 | 885 | 0 | 0 | 963 | $0.0013 |
| gemini | Lua | 1 | v2 | 36 | 854 | 0 | 0 | 890 | $0.0013 |
| gemini | Scheme | 1 | v1 | 78 | 862 | 0 | 0 | 940 | $0.0013 |
| gemini | Scheme | 1 | v2 | 36 | 849 | 0 | 0 | 885 | $0.0013 |
| gemini | Ocaml | 1 | v1 | 80 | 893 | 0 | 0 | 973 | $0.0014 |
| gemini | Ocaml | 1 | v2 | 36 | 819 | 0 | 0 | 855 | $0.0012 |
| gemini | Haskell | 1 | v1 | 78 | 736 | 0 | 0 | 814 | $0.0011 |
| gemini | Haskell | 1 | v2 | 36 | 884 | 0 | 0 | 920 | $0.0013 |
| gemini | Rust | 2 | v1 | 78 | 864 | 0 | 0 | 942 | $0.0013 |
| gemini | Rust | 2 | v2 | 36 | 809 | 0 | 0 | 845 | $0.0012 |
| gemini | Go | 2 | v1 | 78 | 623 | 0 | 0 | 701 | $0.0010 |
| gemini | Go | 2 | v2 | 36 | 701 | 0 | 0 | 737 | $0.0011 |
| gemini | C | 2 | v1 | 78 | 845 | 0 | 0 | 923 | $0.0013 |
| gemini | C | 2 | v2 | 36 | 973 | 0 | 0 | 1,009 | $0.0015 |
| gemini | Typescript | 2 | v1 | 79 | 893 | 0 | 0 | 972 | $0.0014 |
| gemini | Typescript | 2 | v2 | 36 | 756 | 0 | 0 | 792 | $0.0011 |
| gemini | Javascript | 2 | v1 | 78 | 666 | 0 | 0 | 744 | $0.0010 |
| gemini | Javascript | 2 | v2 | 36 | 870 | 0 | 0 | 906 | $0.0013 |
| gemini | Java | 2 | v1 | 78 | 774 | 0 | 0 | 852 | $0.0012 |
| gemini | Java | 2 | v2 | 36 | 630 | 0 | 0 | 666 | $0.0010 |
| gemini | Perl | 2 | v1 | 78 | 722 | 0 | 0 | 800 | $0.0011 |
| gemini | Perl | 2 | v2 | 36 | 802 | 0 | 0 | 838 | $0.0012 |
| gemini | Python | 2 | v1 | 78 | 854 | 0 | 0 | 932 | $0.0013 |
| gemini | Python | 2 | v2 | 36 | 936 | 0 | 0 | 972 | $0.0014 |
| gemini | Python/mypy | 2 | v1 | 116 | 887 | 0 | 0 | 1,003 | $0.0014 |
| gemini | Python/mypy | 2 | v2 | 71 | 1,004 | 0 | 0 | 1,075 | $0.0015 |
| gemini | Ruby | 2 | v1 | 78 | 850 | 0 | 0 | 928 | $0.0013 |
| gemini | Ruby | 2 | v2 | 36 | 836 | 0 | 0 | 872 | $0.0013 |
| gemini | Ruby/steep | 2 | v1 | 114 | 718 | 0 | 0 | 832 | $0.0011 |
| gemini | Ruby/steep | 2 | v2 | 69 | 798 | 0 | 0 | 867 | $0.0012 |
| gemini | Lua | 2 | v1 | 78 | 787 | 0 | 0 | 865 | $0.0012 |
| gemini | Lua | 2 | v2 | 36 | 666 | 0 | 0 | 702 | $0.0010 |
| gemini | Scheme | 2 | v1 | 78 | 832 | 0 | 0 | 910 | $0.0013 |
| gemini | Scheme | 2 | v2 | 36 | 869 | 0 | 0 | 905 | $0.0013 |
| gemini | Ocaml | 2 | v1 | 80 | 807 | 0 | 0 | 887 | $0.0012 |
| gemini | Ocaml | 2 | v2 | 36 | 914 | 0 | 0 | 950 | $0.0014 |
| gemini | Haskell | 2 | v1 | 78 | 679 | 0 | 0 | 757 | $0.0010 |
| gemini | Haskell | 2 | v2 | 36 | 1,108 | 0 | 0 | 1,144 | $0.0017 |
| gemini | Rust | 3 | v1 | 78 | 762 | 0 | 0 | 840 | $0.0012 |
| gemini | Rust | 3 | v2 | 36 | 833 | 0 | 0 | 869 | $0.0013 |
| gemini | Go | 3 | v1 | 78 | 651 | 0 | 0 | 729 | $0.0010 |
| gemini | Go | 3 | v2 | 36 | 907 | 0 | 0 | 943 | $0.0014 |
| gemini | C | 3 | v1 | 78 | 853 | 0 | 0 | 931 | $0.0013 |
| gemini | C | 3 | v2 | 36 | 802 | 0 | 0 | 838 | $0.0012 |
| gemini | Typescript | 3 | v1 | 79 | 903 | 0 | 0 | 982 | $0.0014 |
| gemini | Typescript | 3 | v2 | 36 | 868 | 0 | 0 | 904 | $0.0013 |
| gemini | Javascript | 3 | v1 | 78 | 763 | 0 | 0 | 841 | $0.0012 |
| gemini | Javascript | 3 | v2 | 36 | 739 | 0 | 0 | 775 | $0.0011 |
| gemini | Java | 3 | v1 | 78 | 724 | 0 | 0 | 802 | $0.0011 |
| gemini | Java | 3 | v2 | 36 | 772 | 0 | 0 | 808 | $0.0012 |
| gemini | Perl | 3 | v1 | 78 | 702 | 0 | 0 | 780 | $0.0011 |
| gemini | Perl | 3 | v2 | 36 | 851 | 0 | 0 | 887 | $0.0013 |
| gemini | Python | 3 | v1 | 78 | 927 | 0 | 0 | 1,005 | $0.0014 |
| gemini | Python | 3 | v2 | 36 | 808 | 0 | 0 | 844 | $0.0012 |
| gemini | Python/mypy | 3 | v1 | 116 | 955 | 0 | 0 | 1,071 | $0.0015 |
| gemini | Python/mypy | 3 | v2 | 71 | 958 | 0 | 0 | 1,029 | $0.0015 |
| gemini | Ruby | 3 | v1 | 78 | 720 | 0 | 0 | 798 | $0.0011 |
| gemini | Ruby | 3 | v2 | 36 | 968 | 0 | 0 | 1,004 | $0.0015 |
| gemini | Ruby/steep | 3 | v1 | 114 | 833 | 0 | 0 | 947 | $0.0013 |
| gemini | Ruby/steep | 3 | v2 | 69 | 953 | 0 | 0 | 1,022 | $0.0014 |
| gemini | Lua | 3 | v1 | 78 | 870 | 0 | 0 | 948 | $0.0013 |
| gemini | Lua | 3 | v2 | 36 | 919 | 0 | 0 | 955 | $0.0014 |
| gemini | Scheme | 3 | v1 | 78 | 804 | 0 | 0 | 882 | $0.0012 |
| gemini | Scheme | 3 | v2 | 36 | 887 | 0 | 0 | 923 | $0.0013 |
| gemini | Ocaml | 3 | v1 | 80 | 877 | 0 | 0 | 957 | $0.0013 |
| gemini | Ocaml | 3 | v2 | 36 | 815 | 0 | 0 | 851 | $0.0012 |
| gemini | Haskell | 3 | v1 | 78 | 846 | 0 | 0 | 924 | $0.0013 |
| gemini | Haskell | 3 | v2 | 36 | 847 | 0 | 0 | 883 | $0.0013 |
| gemini | Python | 1 | v1 | 78 | 815 | 0 | 0 | 893 | $0.0012 |
| gemini | Python | 1 | v2 | 36 | 762 | 0 | 0 | 798 | $0.0012 |

