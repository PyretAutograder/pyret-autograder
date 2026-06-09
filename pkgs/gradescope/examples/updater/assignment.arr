provide: find-cursor, get-node-val, update, to-tree, left, right, up, down end
# END HEADER

include file("submission/assignment-support.arr")

# ---- reference implementation ----

fun find-cursor<A>(tree :: Tree<A>, pred :: (A -> Boolean)) -> Cursor<A>:
  doc: "Constructs cursor at first node where pred(tree.value) returns true"
  fun helper(cur :: Cursor<A>) -> Option<Cursor<A>>:
    doc: "Performs a dfs of the tree located at cursor."
    cases (Tree<A>) cur.sub-tree:
      | mt => none
      | node(value, children) =>
        if pred(value):
          some(cur)
        else:
          # Recur on each child, keeping the first result that is not none.
          for fold(
              result :: Option<Cursor<A>> from none,
              child-index from range(0, children.length())):
            cases (Option<Cursor<A>>) result:
              | some(_) => result
              | none => helper(down(cur, child-index))
            end
          end
        end
    end
  end

  cases (Option<Cursor<A>>) helper(cursor(none, tree, empty, empty, empty)):
    | none => raise("Could not find node matching predicate")
    | some(result) =>
      cases (Cursor<A>) result:
        | cursor(a, b, c, d, _) =>
          cursor(a, b, c, d, empty)
      end
  end
end

fun up<A>(cur :: Cursor<A>) -> Cursor<A>:
  doc: "Returns the parent cursor"
  children :: List<Tree<A>> =
    cur.left-trees.foldl(link, link(cur.sub-tree, cur.right-trees))

  cases (Option<Cursor<A>>) cur.parent-cursor:
    | none => raise("Invalid movement")
    | some(parent) =>
      cases (Tree<A>) parent.sub-tree:
        | mt => raise("Shouldn't reach here.")
        | node(value, _) =>
          cursor(
            parent.parent-cursor,
            node(value, children),
            parent.left-trees,
            parent.right-trees,
            cur.actions.push(Up))
      end
  end
end

fun left<A>(cur :: Cursor<A>) -> Cursor<A>:
  doc: "Returns a cursor pointed at the node to the left"
  cases (List<Tree<A>>) cur.left-trees:
    | empty => raise("Invalid movement")
    | link(f, r) =>
      cursor(
        cur.parent-cursor,
        f,
        r,
        link(cur.sub-tree, cur.right-trees),
        cur.actions.push(Left))
  end
end

fun right<A>(cur :: Cursor<A>) -> Cursor<A>:
  doc: "Returns a cursor pointed at the node to the right"
  cases (List<Tree<A>>) cur.right-trees:
    | empty => raise("Invalid movement")
    | link(f, r) =>
      cursor(
        cur.parent-cursor,
        f,
        link(cur.sub-tree, cur.left-trees),
        r,
        cur.actions.push(Right))
  end
end

fun down<A>(cur :: Cursor<A>, child-index :: Number) -> Cursor<A>:
  doc: "Returns a cursor to a child node specified by the index argument"
  cases (Tree<A>) cur.sub-tree block:
    | mt => raise("Shouldn't reach here.")
    | node(_, children) =>
      when (child-index < 0) or (child-index >= children.length()):
        raise("Invalid movement")
      end

      cursor(
        some(cur),
        children.get(child-index),
        children.take(child-index).reverse(),
        children.drop(child-index + 1),
        cur.actions.push(Down))
  end
end

fun update<A>(cur :: Cursor<A>, func :: (Tree<A> -> Tree<A>)) -> Cursor<A>:
  doc: "Updates the cursor's sub-tree with the given tree function"
  cursor(
    cur.parent-cursor,
    func(cur.sub-tree),
    cur.left-trees,
    cur.right-trees,
    cur.actions.push(Update))
end

fun clean-mts<A>(tree :: Tree<A>) -> Tree<A>:
  doc: "Removes all mt's from a given tree."
  cases (Tree<A>) tree:
    | mt => mt
    | node(value, children) =>
      node(value, children.map(clean-mts).filter(is-node))
  end
end

fun to-tree<A>(cur :: Cursor<A>) -> Tree<A>:
  doc: "Returns a tree representation of the given cursor and all updates"
  cases (Option<Cursor<A>>) cur.parent-cursor:
    | none => cur.sub-tree
    | some(_) => to-tree(up(cur))
  end
    ^ clean-mts
end

fun get-node-val<A>(cur :: Cursor<A>) -> Option<A>:
  doc: "Returns the value at the cursor as an option"
  cases (Tree<A>) cur.sub-tree:
    | mt => none
    | node(value, _) => some(value)
  end
end

# ---- fixtures ----

node0 = node(0, empty)
node1 = node(1, empty)
node2 = node(2, empty)
node3 = node(3, empty)
node4 = node(4, empty)
node5 = node(5, empty)

tree1 = node(5, [list: node0])
tree2 = node(5, [list: node1, node5, node3])
tree3 = node(6, [list: node0, node3, tree2, node5])
tree4 = node(6, [list: node4, node3, tree3, node3, tree1, node4])
tree17 = node(6, [list: node0, tree2, node5])

fun pred5(x): x == 5 end

# ---- tests, routed per function under test ----

check "find-cursor":
  get-node-val(find-cursor(node0, lam(x): x == 0 end)) is some(0)
  get-node-val(find-cursor(tree1, lam(x): x == 0 end)) is some(0)
  get-node-val(find-cursor(tree2, lam(x): x == 1 end)) is some(1)
  get-node-val(find-cursor(tree3, lam(x): x == 1 end)) is some(1)
  # missing node must raise (catches "returns cursor when missing")
  find-cursor(mt, lam(x): is-node(x) end) raises ""
  find-cursor(tree1, lam(x): false end) raises ""
  # duplicate values: must find the depth-first, left-to-right first match
  treedup = node(5, [list: node5, node(6, [list: node(4, [list: node1]), node5, node3]), node2, node0])
  get-node-val(find-cursor(treedup, lam(x): x < 5 end)) is some(4)
  # pin the exact node found, proving DFS left-to-right order
  dtree = node(1, [list:
      node(3, empty),
      node(3, [list:
          node(4, [list:
              node(7, [list: node(3, empty), node(2, empty)]),
              node(4, empty)]),
          node(7, empty)]),
      node(7, empty),
      node(5, empty)])
  searched = find-cursor(dtree, lam(x): x == 7 end)
  left(searched) raises "Invalid movement"
  get-node-val(searched) is some(7)
  get-node-val(right(searched)) is some(4)
  get-node-val(down(searched, 0)) is some(3)
  get-node-val(up(searched)) is some(4)
end

check "get-node-val":
  get-node-val(find-cursor(node5, lam(x): x == 5 end)) is some(5)
  get-node-val(find-cursor(tree17, lam(x): x == 3 end)) is some(3)
  # value at an mt node must be none (catches "raises on mt")
  get-node-val(update(find-cursor(tree1, lam(x): x == 0 end), lam(t): mt end)) is none
end

check "to-tree":
  to-tree(find-cursor(tree3, lam(x): x == 5 end)) is tree3
  to-tree(find-cursor(tree4, lam(x): x == 5 end)) is tree4
  to-tree(update(find-cursor(node0, lam(x): x == 0 end), lam(x): mt end)) is mt
  # deleting a child must filter the resulting mt (catches "doesn't filter mts")
  to-tree(update(find-cursor(tree1, lam(x): x == 0 end), lam(x): mt end)) is node5
end

check "up":
  get-node-val(up(find-cursor(tree4, lam(x): x == 1 end))) is some(5)
  # up then up (catches "up then up fails")
  get-node-val(up(up(find-cursor(tree4, lam(x): x == 1 end)))) is some(6)
  # up at the root must raise (catches "illegal up/movement returns input")
  up(find-cursor(node0, lam(x): x == 0 end)) raises ""
end

check "down":
  get-node-val(down(find-cursor(tree4, lam(x): x == 6 end), 0)) is some(4)
  get-node-val(down(find-cursor(tree4, lam(x): x == 6 end), 3)) is some(3)
  # illegal down must raise (catches "illegal down returns input")
  down(find-cursor(node0, lam(x): x == 0 end), 0) raises ""
  down(find-cursor(tree4, lam(x): x == 6 end), 10) raises ""
  down(find-cursor(node0, lam(x): x == 0 end), -1) raises ""
end

check "left":
  get-node-val(left(find-cursor(tree2, lam(x): x == 3 end))) is some(5)
  get-node-val(left(left(find-cursor(tree2, lam(x): x == 3 end)))) is some(1)
  # left past the start must raise (catches "illegal left returns input")
  left(find-cursor(tree2, lam(x): x == 1 end)) raises ""
end

check "right":
  get-node-val(right(find-cursor(tree2, lam(x): x == 1 end))) is some(5)
  get-node-val(right(right(find-cursor(tree2, lam(x): x == 1 end)))) is some(3)
  # right past the end must raise (catches "illegal right returns input")
  right(find-cursor(tree2, lam(x): x == 3 end)) raises ""
end

check "update":
  get-node-val(update(find-cursor(tree3, pred5), lam(x): tree1 end)) is some(5)
  # update then move must work (catches all "update then X fails" chaffs)
  get-node-val(up(update(find-cursor(tree3, pred5), lam(x): tree1 end))) is some(6)
  get-node-val(down(update(find-cursor(tree3, pred5), lam(x): tree1 end), 0)) is some(0)
  get-node-val(left(update(find-cursor(tree3, pred5), lam(x): tree1 end))) is some(3)
  get-node-val(right(update(find-cursor(tree3, pred5), lam(x): tree1 end))) is some(5)
  # update then update must work (catches "update then update fails")
  get-node-val(update(update(find-cursor(tree3, pred5), lam(x): tree1 end), lam(x): tree1 end)) is some(5)
end
