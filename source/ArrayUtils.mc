using Toybox.Math;

import Toybox.Lang;

function sameArray(a1 as Array<Numeric>, a2 as Array<Numeric>) as Boolean
{
    var s1 = a1.size();
    var s2 = a2.size();
    if (s1 != s2) {
        return false;
    }
    for(var i = 0; i < s1; i++) {
        if (a1[i] != a2[i]) {
            return false;
        }
    }
    return true;
}

function copyArray(array as Array<Numeric>) as Array<Numeric>
{
    var arrayCopy = array.slice(0, array.size());
    return arrayCopy;
}

//https://www.geeksforgeeks.org/insertion-sort/
function insertionSort(arr as Array<Numeric>) as Void
{
    var i;
    var key;
    var j;
    for (i = 1; i < arr.size(); i++)
    {
        key = arr[i];
        j = i - 1;
        while (j >= 0 && arr[j] > key)
        {
            arr[j + 1] = arr[j];
            j = j - 1;
        }
        arr[j + 1] = key;
    }
}

function isArraySorted(array as Array<Numeric>) as Boolean
{
    var arraySize = array.size();
    if(array.size() == 0) {
        return true;
    }
    var prev = array[0];
    for(var i = 1; i < arraySize; i ++) {
        var current = array[i];
        if(prev > current) {
            return false;
        }
        prev = current;
    }
    return true;
}

// https://www.techiedelight.com/iterative-merge-sort-algorithm-bottom-up/
function mergesort(A as Array<Numeric>) as Void
{
    var lastIndex = A.size() - 1;
    var tempArray = copyArray(A);
    for(var m = 1; m <= lastIndex; m = 2*m){
        for (var i = 0; i < lastIndex; i += 2*m)
        {
            var from = i;
            var mid = i + m - 1;
            var to = min(i + 2*m - 1, lastIndex);
            merge(A, tempArray, from, mid, to);
        }
    }
}

/**********************************************
    PRIVATE STUFF BELOW
***********************************************/
function min(x as Numeric, y as Numeric) as Numeric
{
    return (x < y) ? x : y;
}

function merge(A as Array<Numeric>, tempArray as Array<Numeric>, from as Numeric,
            mid as Numeric, to as Numeric) as Void
{
    var k = from;
    var i = from;
    var j = mid + 1;

    while(i <= mid && j <= to)
    {
        if (A[i] < A[j]) {
            tempArray[k] = A[i];
            i++;
        } else {
            tempArray[k] = A[j];
            j++;
        }
        k++;
    }

    while(i < A.size() && i <= mid) {
        tempArray[k] = A[i];
        k++;
        i++;
    }

    for(i = from; i <= to; i++) {
        A[i] = tempArray[i];
    }
}
