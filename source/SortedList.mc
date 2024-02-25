import Toybox.Lang;

typedef Numeric as Number or Float or Long or Double;

class NodeList
{
    var m_value as Numeric;
    var m_next as NodeList or Null;

    function initialize(value as Numeric, next as NodeList or Null)
    {
        m_value = value;
        m_next = next;
    }
}

class SortedList
{
    var m_length as Number;
    var m_first as NodeList or Null;

    function initialize()
    {
        m_first = null;
        m_length = 0;
    }

    function free() as Void
    {
        var it = m_first;
        m_first = null;
        for(var i = 0; i < m_length; i++)
        {
            var next = it.m_next;
            it.m_next = null;
            it = next;
        }
    }

    function size() as Number
    {
        return m_length;
    }

    function insertSortedArray(array as Array<Numeric>) as Void
    {
        var i = 0;
        if(m_first == null) {
            m_first = new NodeList(array[0], null);
            i++;
            m_length++;
        }
        var prevIt = null;
        var it = m_first;
        for(; i < array.size(); i++) {
            var valueToInsert = array[i];
            while(it.m_value <= valueToInsert) {
                if(it.m_next == null) {
                    break;
                }
                prevIt = it;
                it = it.m_next;
            }
            if(it.m_value > valueToInsert) {
                // insert in list
                var newNode = new NodeList(valueToInsert, it);
                if(prevIt != null) {
                    prevIt.m_next = newNode;
                } else {
                    m_first = newNode;
                }
                prevIt = newNode;
            } else {
                // append to list
                var newNode = new NodeList(valueToInsert, it.m_next);
                it.m_next = newNode;
            }
            m_length++;
        }
    }
}