#!/usr/bin/env ruby
#
# 「宣教師と人食い」
# 3人の宣教師と３人の人食い人種が、舟を使って向こう岸まで渡ろうとしている。
# 舟には２人まで乗ることができる。
# ところが、宣教師の数がそこにいる人食い人種の数より少なくなると、彼らに殺されてしまう。
# 全員無事に向こう岸まで渡るにはどうすればよいか。
#
module MissionariesAndCannibals
  class Puzzle
    def initialize
      @snapshot = {:here => [3,3], :opposite => [0,0]}
      @boat = :here
      @trip_number = 0
      @history = {}
      memorize
    end
    
    def memorize
      @history[@trip_number] = @snapshot.to_s.freeze
    end
    
    def cross_river!(missionary, cannibal)
      @snapshot[@boat] = @snapshot[@boat].zip([missionary, cannibal]).map{|f,s|f-s}
      @boat = other_side
      @snapshot[@boat] = @snapshot[@boat].zip([missionary, cannibal]).map{|f,s|f+s}
      @trip_number += 1
      memorize
    end
    
    def next_possible_list
      plist = []
      each_possible do |missionary, cannibal|
        puzzle = dup
        puzzle.cross_river! missionary, cannibal
        plist << puzzle
      end
      plist
    end
    
    def each_possible
      0.upto(2) do |missionary| 
        0.upto(2 - missionary) do |cannibal|
          next if missionary == 0 && cannibal == 0
          yield missionary, cannibal if possible? missionary, cannibal
        end
      end
    end
    
    def possible?(missionary, cannibal)
      check_bank_state = lambda{|bank_state| (bank_state[0] >= 0 && bank_state[1] >= 0) && \
              bank_state[0] >= bank_state[1] || bank_state[0] == 0}
      check_bank_state.call(@snapshot[@boat].zip([missionary, cannibal]).map{|f,s|f-s}) && \
      check_bank_state.call(@snapshot[other_side].zip([missionary, cannibal]).map{|f,s|f+s})
    end
    
    def other_side
      @boat == :here ? :opposite : :here
    end
    
    def solved?
      @snapshot[:opposite] == [3,3]
    end
    
    def to_s
      @history.collect{|trip_number, snapshot| "#{trip_number} : #{snapshot}"}.join("\n")
    end
    
    def dup
      copy = super
      @snapshot = @snapshot.reduce({}) do |sdup, (boat, e)|
        sdup[boat] = e.dup
        sdup
      end
      @history = @history.dup
      copy
    end
  end
  
  # 一手進めるごとに場合の数だけインスタンスを生成し、
  # 解けたものが見つかったらそのインスタンスを返す。
  def MissionariesAndCannibals.solve(puzzle)
    plist = [puzzle]
    until plist.any? {|each| each.solved?}
      plist = plist.reduce([]) do |next_list, each|
        next_list.concat each.next_possible_list
      end
    end
    plist.find {|each| each.solved?}
  end
end

p MissionariesAndCannibals::solve MissionariesAndCannibals::Puzzle.new

# --------- 実行結果 ---------
# 0 : {:here=>[3, 3], :opposite=>[0, 0]}
# 1 : {:here=>[3, 1], :opposite=>[0, 2]}
# 2 : {:here=>[3, 2], :opposite=>[0, 1]}
# 3 : {:here=>[3, 0], :opposite=>[0, 3]}
# 4 : {:here=>[3, 1], :opposite=>[0, 2]}
# 5 : {:here=>[1, 1], :opposite=>[2, 2]}
# 6 : {:here=>[2, 2], :opposite=>[1, 1]}
# 7 : {:here=>[0, 2], :opposite=>[3, 1]}
# 8 : {:here=>[0, 3], :opposite=>[3, 0]}
# 9 : {:here=>[0, 1], :opposite=>[3, 2]}
# 10 : {:here=>[0, 2], :opposite=>[3, 1]}
# 11 : {:here=>[0, 0], :opposite=>[3, 3]}
