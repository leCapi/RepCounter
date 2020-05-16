using Toybox.Test;
using Toybox.System;

(:test)
function tcopyArray(logger)
{
    var array = [898, 90889, -744, 1234, 2, 392, -33, 90];
    var newArray = copyArray(array);
    Test.assertNotEqual(array, newArray);
    Test.assertEqual(array.size(), newArray.size());
    for (var i = 0 ; i < array.size(); i++)
    {
        Test.assertEqualMessage(array[i], newArray[i], "copy failed");
    }

    return true;
}

(:test)
function tInsertionSort(logger)
{
    var array = [898, 90889, -744, 1234, 2, 392, -33, 90];
    var arrayExpected = [-744, -33, 2, 90, 392, 898, 1234, 90889];
    insertionSort(array);
    for (var i = 0 ; i < array.size(); i++)
    {
        Test.assertEqualMessage(array[i], arrayExpected[i], "sort failed");
    }

    return true;
}

(:test)
function tIsArraySorted(logger)
{
    var array = [898, 90889, -744, 1234, 2, 392, -33, 90];
    Test.assertEqual(isArraySorted(array), false);

    array = [1,2,3,4,5];
    Test.assertEqual(isArraySorted(array), true);

    return true;
}


(:test)
function tMergeSort(logger)
{
    var array = [898, 90889, -744, 1234, 2, 2, 392, -33, 90];
    mergesort(array);
    Test.assertEqualMessage(isArraySorted(array), true, "sort failed");
    Test.assertEqualMessage(array.size(), 9, "sort failed");

    return true;
}
