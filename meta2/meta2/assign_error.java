class assign_error {
  public static void main(String[] args) {
    f(i = j = a&&b = l);
  }
}

/*
ID
    ASSIGN
        ID
            ASSIGN
                ID
                    AND
                        ID
                            ASSIGN
                                ID

f(i = (j = ((a && b) = j)))

f(i = (j = (a && (b = j))))  esta a fazer

ID ASSIGN (ID ASSIGN (ID AND (ID ASSIGN ID)))
 */