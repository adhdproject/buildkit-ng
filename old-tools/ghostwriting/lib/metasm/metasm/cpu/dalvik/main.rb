#    This file is part of Metasm, the Ruby assembly manipulation suite
#    Copyright (C) 2006-2009 Yoann GUILLOT
#
#    Licence is LGPL, see LICENCE in the top-level directory


require 'metasm/main'

module Metasm
class Dalvik < CPU
  class Reg
    attr_accessor :i
    def initialize(i)
      @i = i
    end

    def symbolic
      "r#@i".to_sym
    end

    def to_s
      "r#@i"
    end
  end

  class DexMethod
    attr_accessor :dex, :midx, :off
    def initialize(dex, midx)
      @dex = dex
      @midx = midx
      if @dex and m = @dex.methods[midx] and c = @dex.classes[m.classidx] and c.data and
        me = (c.data.direct_methods+c.data.virtual_methods).find { |mm| mm.methodid == midx }
        # FIXME this doesnt work
        @off = me.codeoff + me.code.insns_off
      end
    end

    def to_s
      if @dex and m = @dex.methods[@midx]
        @dex.types[m.classidx] + '->' + @dex.strings[m.nameidx]
        #dex.encoded.inv_export[@off]
      else
        "method_#@midx"
      end
    end
  end

  class DexField
    attr_accessor :dex, :fidx
    def initialize(dex, fidx)
      @dex = dex
      @fidx = fidx
    end

    def to_s
      if @dex and f = @dex.fields[@fidx]
        @dex.types[f.classidx] + '->' + @dex.strings[f.nameidx]
      else
        "field_#@fidx"
      end
    end
  end

  class DexType
    attr_accessor :dex, :tidx
    def initialize(dex, tidx)
      @dex = dex
      @tidx = tidx
    end

    def to_s
      if @dex and f = @dex.types[@tidx]
        f
      else
        "type_#@tidx"
      end
    end
  end

  class DexString
    attr_accessor :dex, :sidx
    def initialize(dex, sidx)
      @dex = dex
      @sidx = sidx
    end

    def to_s
      if @dex and f = @dex.strings[@sidx]
        f.inspect
      else
        "string_#@sidx"
      end
    end
  end

  def initialize(*args)
    super()
    @size = args.grep(Integer).first || 32
    @dex = args.grep(ExeFormat).first
    @endianness = args.delete(:little) || args.delete(:big) || (@dex ? @dex.endianness : :little)
  end

  def init_opcode_list
    init_latest
    @opcode_list
  end
end
end

