class NodeList
{
    var m_value;
    var m_next;

    function initialize(value, next)
    {
        m_value = value;
        m_next = next;
    }
}

class SortedList
{
    var m_length;
    var m_first;

    function initialize()
    {
        m_first = null;
        m_length = 0;
    }

    function insertSortedArray(array)
    {
        var i = 0;
        var it = m_first;
        var prevIt = null;
        if(m_first == null) {
            m_first = new NodeList(array[0], null);
            it = m_first;
            i++;
            m_length++;
        }
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
                    prevIt = newNode;
                }
            } else {
                // append to list
                var newNode = new NodeList(valueToInsert, null);
                it.m_next = newNode;
            }
            m_length++;
        }
    }
}