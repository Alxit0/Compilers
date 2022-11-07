class assign_error {
  public static void main(String[] args) {
    f(i = j = a&&b = l);
  }
}

/*
0
1
3
5
6
10
14
    18
    21
    25
    31
    54
    86
    123
20
    23
    29
    ID 47
    LPAR 80
    ID(i) 67
    ASSIGN 81
    ID(j) 67
    ASSIGN 81
        ID(a) 67
    120
    AND 104
*/