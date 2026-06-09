provide *
provide-types *

# The given tree type.
data Tree<A>:
  | mt
  | node(value :: A, children :: List<Tree<A>>)
end

# Action history carried by the cursor.  Correct implementations never need to
# inspect it, but the representation is shared by every wheat/chaff (some chaffs
# raise based on the most recent action), so it lives here in the shared
# support module -- the wheat/chaff merge replaces only top-level `fun`s and
# drops alternate `data` definitions, so the Cursor/Action types must be common.
data Action:
  | Up
  | Down
  | Left
  | Right
  | Update
end

data Cursor<A>:
  | cursor(
      parent-cursor :: Option<Cursor<A>>,
      sub-tree :: Tree<A>,
      left-trees :: List<Tree<A>>,  # inside first
      right-trees :: List<Tree<A>>, # inside first
      actions :: List<Action>)      # most-recent action first
end
