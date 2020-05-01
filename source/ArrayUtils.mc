using Toybox.Math;

function sameArray(a1, a2)
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

function copyArray(array)
{
    var arrayCopy = array.slice(0, array.size());
    return arrayCopy;
}

//https://www.geeksforgeeks.org/insertion-sort/
function insertionSort(arr)
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

function isArraySorted(array)
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

// this class aims to avoid the Watchdog Tripped
// it can perform a merge in several steps
const MERGER_NB_LOOP_PER_CYCLE = 75;
class MergeSorter
{
    var m_iterator;
    var m_arrayToSort;
    var m_tmpArray;
    var m_li;
    var m_loop = 1;


    function initialize(array)
    {
        self.m_iterator = 0;
        self.m_arrayToSort = array;
        self.m_tmpArray = copyArray(array);
        self.m_li = array.size() - 1;
    }

    function nbLoopNeeded()
    {
        return Math.ceil(Math.log(m_arrayToSort.size(),2)).toNumber();
    }

    function sortingDone()
    {
        return m_loop > m_li;
    }

    function sortIterate()
    {
        for (var i = 0; i < m_li; i += 2*m_loop)
        {
            var from = i;
            var mid = i + m_loop - 1;
            var to = min(i + 2*m_loop - 1, m_li);
            merge(m_arrayToSort, m_tmpArray, from, mid, to);
        }
        m_loop = 2*m_loop;
    }
}

// https://www.techiedelight.com/iterative-merge-sort-algorithm-bottom-up/
function mergesort(A)
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
function min(x, y)
{
    return (x < y) ? x : y;
}

function merge(A, tempArray, from, mid, to)
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
