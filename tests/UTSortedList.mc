using Toybox.Test;
using Toybox.System;

(:test)
function tInsertSortedArray(logger)
{
    var array = [-3, -2, 5, 9];
    var list = new SortedList();
    list.insertSortedArray(array);
    Test.assertEqual(list.size(), 4);

    var array2 = [-8, -5, 8, 9, 10, 11];
    list.insertSortedArray(array2);
    Test.assertEqual(list.m_length, 10);

    var expectedRes = [-8, -5, -3, -2, 5, 8, 9, 9, 10, 11];
    var itList = list.m_first;
    for(var i = 0; i < expectedRes.size(); i++) {
        Test.assertEqual(expectedRes[i], itList.m_value);
        itList = itList.m_next;
    }

    return true;
}