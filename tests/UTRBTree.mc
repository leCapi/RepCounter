using Toybox.System;
using Toybox.Test;

(:test)
function tRBTree(logger)
{
    var array = [898, 90889, -744, 1234, 2, 392, -33, 90, 2];
    var arrayExpected = [-744, -33, 2, 2, 90, 392, 898, 1234, 90889];
    var tree = new RBTree();
    for (var i = 0 ; i < array.size(); i++)
    {
        tree.insert(array[i]);
        Test.assertEqual(tree.size(), i + 1);
    }
    tree.dumpInArray();
    var arr = tree.m_dataInSortedArray;
    var sz = arr.size();
    var expectedSz = arrayExpected.size();
    Test.assertEqualMessage(sz, expectedSz, "wrong size, got : " + sz + ", expected : " + expectedSz);
    Test.assertEqual(isArraySorted(arr), true);

    // test insertAll()
    tree = new RBTree();
    tree.insertAll(array);
    tree.dumpInArray();
    arr = tree.m_dataInSortedArray;
    sz = arr.size();
    expectedSz = arrayExpected.size();
    Test.assertEqualMessage(sz, expectedSz, "wrong size, got : " + sz + ", expected : " + expectedSz);
    Test.assertEqual(isArraySorted(arr), true);

    return true;
}