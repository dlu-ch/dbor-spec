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
- Precise:
  There is no undefined behaviour;
  all conformant implementations encode and decode in exactly the same way.
- Very fast to encode and decode:
  Encoders and decoders do not have to copy large data blocks;
  decoding and checks for validity require only "fast" operations and no "large" iterations;
  suitable for real-time applications.
- Compact:
  Little memory overhead and therefore suitable for
  storing in small EEPROM or transmission over slow medium.
- Scalable:
  Defines conformance levels for implementations;
  this allows trade-offs between code size / complexity and features
  and simple compatibility checks.
- Supports fine-grained size hints (pre-allocation):
  Allows the description of memory layouts and efficient replacements
  of small parts of large structures.

Latest version of the specification: `here <https://github.com/dlu-ch/dbor-spec/releases/latest/download/dbor.pdf>`_.

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
