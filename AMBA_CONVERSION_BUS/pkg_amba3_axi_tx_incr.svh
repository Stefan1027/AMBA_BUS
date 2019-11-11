/*==============================================================================

The MIT License (MIT)

Copyright (c) 2014 Luuvish Hwang

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

================================================================================

    File         : pkg_amba3_axi_tx_incr.svh
    Author(s)    : luuvish (github.com/luuvish/amba3-vip)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : package for amba 3 axi increment transaction

==============================================================================*/

class amba3_axi_tx_incr_t #(
  TXID_BITS = 4, ADDR_BITS = 32, DATA_BITS = 32, BEAT_BITS = 32
)
extends amba3_axi_tx_t #(TXID_BITS, ADDR_BITS, DATA_BITS);

  localparam integer BEAT_BASE = $clog2(BEAT_BITS / 8);

  typedef logic [BEAT_BITS - 1:0] beat_t;

  constraint mode_c {
    BEAT_BITS <= DATA_BITS;
    addr.burst == INCR;
  }

  function new (input addr_t addr, beat_t beats [] = {}, int size = 0);
    assert (BEAT_BITS <= DATA_BITS);
    assert ((size | beats.size) > 0);

    this.mode = (size > beats.size ? READ : WRITE);
    this.txid = $urandom_range(0, (1 << TXID_BITS) - 1);

    this.addr = '{
      addr : addr,
      len  : (size | beats.size) - 1,
      size : BEAT_BASE,
      burst: INCR,
      lock : NORMAL,
      cache: cache_attr_t'('0),
      prot : NON_SECURE
    };

    foreach (beats [i]) begin
      int upper, lower;
      addr_t addr = beat(i, upper, lower);

      this.data[i] = '{
        data: beats[i] << (lower * 8),
        strb: ('1 & ((1 << (upper + 1 - lower)) - 1)) << lower,
        resp: OKAY,
        last: (i == this.addr.len)
      };
    end

    this.resp = OKAY;
  endfunction

endclass
