#!/usr/bin/env ruby
#
# �u�鋳�t�Ɛl�H���v
# 3�l�̐鋳�t�ƂR�l�̐l�H���l�킪�A�M���g���Č������݂܂œn�낤�Ƃ��Ă���B
# �M�ɂ͂Q�l�܂ŏ�邱�Ƃ��ł���B
# �Ƃ��낪�A�鋳�t�̐��������ɂ���l�H���l��̐���菭�Ȃ��Ȃ�ƁA�ނ�ɎE����Ă��܂��B
# �S�������Ɍ������݂܂œn��ɂ͂ǂ�����΂悢���B
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
  
  # ���i�߂邲�Ƃɏꍇ�̐������C���X�^���X�𐶐����A
  # ���������̂����������炻�̃C���X�^���X��Ԃ��B
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

# --------- ���s���� ---------
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
