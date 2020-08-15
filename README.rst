|cc-by-4.0|

.. |cc-by-4.0| image:: https://licensebuttons.net/l/by/4.0/88x31.png
   :alt: CC-BY 4.0
   :target: https://creativecommons.org/licenses/by/4.0/

DBOR specification
==================

DBOR (short for Dense Binary Object Representation) specifies the representation of structured data by sequences
of bytes. Think of it as a binary XML or JSON.

It is inspired by `CBOR <http://cbor.io/>`_ and
`Google Protocol Buffers <https://developers.google.com/protocol-buffers>`_
but is much simpler and more efficient in many ways.
 
Main features:

- Powerful:
  Can represent integers up to 65 bit, IEEE-754 binary floating-point numbers of to 64 bit,
  decimal floating point numbers up to 130 bit, byte and Unicode strings, sequences and dictionaries.
- Precise and unambiguous:
  Compliant implementations on all platforms encode and decode in exactly the same way (to the last bit).
- Very fast:
  Decoding and checks for validity require only "fast" operations and no "large" iterations;
  suitable for real-time applications.
- Compact:
  The memory overhead is small; DBOR encoded data is suitable for storing in small EEPROMs
  or transmitting over slow media.
- Scalable:
  Defines conformance levels for implementations to control the trade-off between small code size and complexity
  vs. feature richness.
- Supports fine-grained memory layout control:
  Allows to define a fixed size for each object.

Latest version of the specification: `here <https://github.com/dlu-ch/dbor-spec/releases/latest/download/dbor.pdf>`_.

Online DBOR encoder (conformance level 5): `dbor-js <https://dlu-ch.github.io/dbor-js/encoder.html>`_.

A complete Python 3 implementation of a DBOR encoder (conformance level 2) looks like this:

.. code-block:: python

   def integer_token(h, v):
       b = h << 5
       if v <= 23:
           return bytes([b | v])

       s = b''
       v -= 23
       while v > 0:
           v -= 1
           s += bytes([v % 256])
           v = v // 256
           if len(s) > 8:
               raise ValueError('too large')

       return bytes([b | (23 + len(s))]) + s

   def encoded(value):
       if value is None:
           return b'\xFF'
       if isinstance(value, int):
           return integer_token(0, value) if value >= 0 else integer_token(1, -value - 1)
       if isinstance(value, bytes):
           return integer_token(2, len(value)) + value
       if isinstance(value, str):
           u = value.encode()
           return integer_token(3, len(u)) + u
       if isinstance(value, (list, tuple)):
           s = b''.join(encoded(e) for e in value)
           return integer_token(4, len(s)) + s
       raise TypeError('unsupported')
