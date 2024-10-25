#!/usr/bin/bash

awk '
    BEGIN {malignant=0; normal=0;}
    NR>1 {
        if ($6 == "malignant") malignant++;
        else if ($6 == "normal") normal++;
    }
    END {
        total = malignant + normal;
        if (total > 0) {
            printf "malignant: %.2f%%\n", (malignant / total) * 100;
            printf "normal: %.2f%%\n", (normal / total) * 100;
        } else {
            print "No entries found for malignant or normal.";
        }
    }
' $1
