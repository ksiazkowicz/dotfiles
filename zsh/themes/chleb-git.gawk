BEGIN {
    ORS = "";
    fatal = 0;
    oid = "";
    head = "";
    upstream = "";
    ahead = 0;
    behind = 0;
    untracked = 0;
    unmerged = 0;
    staged = 0;
    unstaged = 0;
    stashed = 0;
}
$1 == "fatal:" {
    fatal = 1;
}
$2 == "branch.oid" {
    oid = $3;
}
$2 == "branch.head" {
    head = $3;
}
$2 == "branch.upstream" {
    upstream = $3;
}
$2 == "branch.ab" {
    ahead = $3;
    behind = $4;
}
$1 == "?" {
    ++untracked;
}
$1 == "u" {
    ++unmerged;
}
$1 == "1" || $1 == "2" {
    split($2, arr, "");
    if (arr[1] != ".") {
        ++staged;
    }
    if (arr[2] != ".") {
        ++unstaged;
    }
}
$2 == "stash.count" {
    stashed = $3;
}
END {
    if (fatal == 1) {
        exit(1);
    }

    if (unstaged > 0) {
        print "● "
    }

    if (head == "(detached)") {
        print "(detached) ";
        print substr(oid, 0, 7);
    } else {
        print BRANCH;
        gsub("%", "%%", head);
        print head;
    }
    print " ";
    if (behind < 0) {
        print "↓";
        printf "%d", behind * -1;
        if (ahead > 0) {
            print " ";
        }
    }
    if (ahead > 0) {
        print "↑";
        printf "%d", ahead;
    }
    if (ahead == 0 && behind == 0) {
        print "≡";
    }
}