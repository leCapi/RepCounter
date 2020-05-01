// code from
// https://www.geeksforgeeks.org/c-program-red-black-tree-insertion/
// modified to allow duplicate values and translated into monkey-c

// enum replaced by boolean to reduce memory footprint
//enum
//{
//    true,
//    false
//}

class Couple
{
    var e1;
    var e2;

    function initialize(a,b)
    {
        e1 = a;
        e2 =b;
    }
}

class Node
{
    var m_data;
    var m_color;
    var m_left;
    var m_right;
    var m_parent;

    // Constructor
    function initialize(m_data)
    {
       self.m_data = m_data;
       self.m_left = null;
       self.m_right = null;
       self.m_parent = null;
       self.m_color = true;
    }
}

// Class to represent Red-Black Tree
class RBTree
{
    private var m_root;
    private var m_itArrayOrder;
    var m_dataInSortedArray;
    var m_size;

    function initialize()
    {
        m_root = null;
        m_itArrayOrder = 0;
        m_size = 0;
        m_dataInSortedArray = null;
    }

    function size()
    {
        return m_size;
    }

    function insert(data)
    {
        var pt = new Node(data);
        m_root = BSTInsert(m_root, pt);
        var c = fixViolation(m_root, pt);
        m_root = c.e1;
        m_size++;
    }

    function insertAll(data)
    {
        for(var i = 0; i < data.size(); i++){
            insert(data[i]);
        }
    }

    function dumpInArray()
    {
        m_itArrayOrder = 0;
        m_dataInSortedArray = new [m_size];
        inorderHelper(m_root);
    }

    function inorderHelper(rt)
    {
        if (rt == null) {
          return;
        }
        inorderHelper(rt.m_left);
        m_dataInSortedArray[m_itArrayOrder] = rt.m_data;
        m_itArrayOrder++;
        inorderHelper(rt.m_right);
    }

    // IMPLEM STUFF
    function BSTInsert(rt, pt)
    {
        /* If the tree is empty, return a new node */
        if (rt == null) {
            return pt;
        }

        /* Otherwise, recur down the tree */
        if (pt.m_data < rt.m_data) {
            rt.m_left  = BSTInsert(rt.m_left, pt);
            rt.m_left.m_parent = rt;
        } else if (pt.m_data >= rt.m_data) {
            rt.m_right = BSTInsert(rt.m_right, pt);
            rt.m_right.m_parent = rt;
        }

        /* return the (unchanged) node pointer */
        return rt;
    }

    function rotateLeft(rt, pt)
    {
        var pt_right = pt.m_right;

        pt.m_right = pt_right.m_left;

        if(pt.m_right != null){
            pt.m_right.m_parent = pt;
        }

        pt_right.m_parent = pt.m_parent;

        if(pt.m_parent == null) {
            rt = pt_right;
        } else if(pt == pt.m_parent.m_left){
            pt.m_parent.m_left = pt_right;
        }else{
            pt.m_parent.m_right = pt_right;
        }

        pt_right.m_left = pt;
        pt.m_parent = pt_right;

        return new Couple(rt, pt);
    }

    function rotateRight(rt, pt)
    {
        var pt_left = pt.m_left;

        pt.m_left = pt_left.m_right;

        if (pt.m_left != null){
            pt.m_left.m_parent = pt;
        }

        pt_left.m_parent = pt.m_parent;

        if (pt.m_parent == null){
            rt = pt_left;
        }
        else if (pt == pt.m_parent.m_left) {
            pt.m_parent.m_left = pt_left;
        }
        else {
            pt.m_parent.m_right = pt_left;
        }

        pt_left.m_right = pt;
        pt.m_parent = pt_left;

        return new Couple(rt, pt);
    }

    // This function fixes violations caused by BST insertion
    function fixViolation(rt, pt)
    {
        var parent_pt = null;
        var grand_parent_pt = null;

        while ((pt != rt) && (pt.m_color != false) &&
            (pt.m_parent.m_color == true)){
            parent_pt = pt.m_parent;
            grand_parent_pt = pt.m_parent.m_parent;

            /*  Case : A
                m_parent of pt is m_left child of Grand-m_parent of pt */
            if (parent_pt == grand_parent_pt.m_left){
                var uncle_pt = grand_parent_pt.m_right;
                /* Case : 1
                    The uncle of pt is also red
                    Only Recoloring required */
                if (uncle_pt != null && uncle_pt.m_color == true){
                    grand_parent_pt.m_color = true;
                    parent_pt.m_color = false;
                    uncle_pt.m_color = false;
                    pt = grand_parent_pt;
                } else {
                /* Case : 2
                   pt is m_right child of its m_parent
                   m_left-rotation required */
                    if (pt == parent_pt.m_right) {
                        var c = rotateLeft(rt, parent_pt);
                        rt = c.e1;
                        parent_pt = c.e2;
                        pt = parent_pt;
                        parent_pt = pt.m_parent;
                    }
                /* Case : 3
                   pt is m_left child of its m_parent
                   m_right-rotation required */
                    var c = rotateRight(rt, grand_parent_pt);
                    rt = c.e1;
                    grand_parent_pt = c.e2;
                    var tmp = parent_pt.m_color;
                    parent_pt.m_color = grand_parent_pt.m_color;
                    grand_parent_pt.m_color = tmp;
                    pt = parent_pt;
                }
            }else{
            /* Case : B
             * m_parent of pt is m_right child of Grand-m_parent of pt */
                var uncle_pt = grand_parent_pt.m_left;
                /*  Case : 1
                    The uncle of pt is also red
                    Only Recoloring required */
                if ((uncle_pt != null) && (uncle_pt.m_color == true)){
                    grand_parent_pt.m_color = true;
                    parent_pt.m_color = false;
                    uncle_pt.m_color = false;
                    pt = grand_parent_pt;
                } else {
                /* Case : 2
                   pt is m_left child of its m_parent
                   m_right-rotation required */
                    if (pt == parent_pt.m_left){
                        var c = rotateRight(rt, parent_pt);
                        rt = c.e1;
                        parent_pt = c.e2;
                        pt = parent_pt;
                        parent_pt = pt.m_parent;
                    }
                /* Case : 3
                   pt is m_right child of its m_parent
                   m_left-rotation required */
                    var c = rotateLeft(rt, grand_parent_pt);
                    rt = c.e1;
                    grand_parent_pt = c.e2;
                    var tmp = parent_pt.m_color;
                    parent_pt.m_color = grand_parent_pt.m_color;
                    grand_parent_pt.m_color = tmp;
                    pt = parent_pt;
                }
            }
        }
        rt.m_color = false;
        return new Couple(rt, pt);
    }

}
