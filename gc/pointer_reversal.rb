class Record
  def initialize(name, fields = [])
    @name = name
    @fields = fields
    @fields ||= []
    @marked = false
  end

  def f
    @fields
  end

  def mark
    debug "Marked #{self}"
    @marked = true
  end

  def marked?
    @marked
  end

  def to_s
    "<record #{@name} marked=#{@marked}>"
  end
end

$indent = 0
def debug(s)
  print ' ' * $indent
  puts s
end

# Assume all records are pointers
def dfs(x)
  return if x.marked?
  t = nil
  done = {}
  # Mark x
  x.mark
  # Start with first index 
  done[x] = 0
  $indent = 0
  while true
    i = done[x]
    debug("DFS #{x}[#{i}]")
    if i < x.f.size
      y = x.f[i]
      if !y.marked?
        x.f[i] = t
        t = x
        $indent += 2
        x = y
        x.mark # x is x.f[i] in this iteration
        done[x] = 0
      else
        done[x] = i + 1
      end
    else
      # We've marked all fields
      # x is the last field we marked
      y = x
      # t is the parent of the field we marked
      debug("Restore #{t}")
      x = t
      $indent -= 2
      return if x.nil?
      i = done[x] # Restore the previous index
      t = x.f[i] # Restore previous parent
      x.f[i] = y # Restore previous value
      done[x] = i + 1
    end
  end
end

gc1 = Record.new('gchild1')
c1 = Record.new('child1', [gc1])
c2 = Record.new('child2')
a = Record.new('parent', [c1, c2])

dfs(a)
pp a
