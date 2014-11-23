module SHA1

  def fill_string(str)
    block_amount = ((str.length + 8 ) >> 6) + 1
    blocks = []

    for i in 0...(block_amount * 16)
      blocks[i] = 0
    end

    for i in 0...str.length
      blocks[i >> 2] += str[i].ord << (24 - (i & 3) * 8)
    end

    blocks[(str.length + 1) >> 2] += 0x80 << (24 - ((str.length + 1) & 3) * 8)
    blocks[block_amount * 16 - 1] = str.length * 8
    blocks
  end

  def bin_to_hex(bin_array)
    hex_string = "0123456789abcdef"
    str = ''

    for i in 0...(bin_array.length * 4)
      str << hex_string[((bin_array[i >> 2] >> ((3 - i % 4) * 8 + 4)) & 0xF)] + hex_string[((bin_array[i >> 2] >> ((3 - i % 4) * 8)) & 0xF)]
    end
    return str
  end

  def core_function(block_array)
    w = []
    a = 0x67452301
    b = 0xEFCDAB89
    c = 0x98BADCFE
    d = 0x10325476
    e = 0xC3D2E1F0

    for i in (0...block_array.length).step(16)
      olda = a
      oldb = b
      oldc = c
      oldd = d
      olde = e

      for j in 0...80
        if j < 16
          w[j] = block_array[i + j]
        else
          w[j] = cyclic_shift(w[j-3] ^ w[j-8] ^ w[j-14] ^ w[j-16], 1)
        end
        t = mod_plus(mod_plus(cyclic_shift(a,5), ft(j, b, c, d)), mod_plus(mod_plus(e, w[j]), kt(j)))
        e = d
        d = c
        c = cyclic_shift(b, 30)
        b = a
        a = t
      end

      a = mod_plus(a, olda)
      b = mod_plus(b, oldb)
      c = mod_plus(c, oldc)
      d = mod_plus(d, oldd)
      e = mod_plus(e, olde)
    end
    return [a, b, c, d, e]
  end

  def ft(t, b, c, d)
    if t < 20
      return (b & c) | ((~b) & d)
    elsif t < 40
      return b ^ c ^ d
    elsif t < 60
      return (b & c) | (b & d) | (c & d)
    else
      return b ^ c ^ d
    end     
  end

  def kt(t)
    return  t < 20 ? 0x5A827999 :
            t < 40 ? 0x6ED9EBA1 :
            t < 60 ? 0x8F1BBCDC : 0xCA62C1D6
  end

  def mod_plus(x, y)
    low = (x & 0xFFFF) + (y & 0xFFFF)
    high = (x >> 16) + (y >> 16) + (low >> 16)

    return (high << 16) | (low & 0xFFFF)
  end

  def cyclic_shift(num, k)
    return (num << k) | (num >>> (32 - k))
  end

  def sha1(s)
    return bin_to_hex(core_function(fill_string(s)))
  end

end


p SHA1.sha1('hey')







