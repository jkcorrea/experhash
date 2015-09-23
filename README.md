ExPerHash
=========

Perceptual hashing for images. Implemented as a C++ program connected to 
Elixir via a port.


##Installation

Requires [Magick++](http://www.imagemagick.org/Magick++/), the ImageMagick
C++ API. Check your package manager or the [ImageMagick downloads page](http://www.imagemagick.org/script/binary-releases.php).

For use in a mix project, add ExPerHash to the `mix.exs` dependencies:

```elixir
def deps do
  [{:experhash, github: "kemonomachi/experhash"}]
end
```

Download by using:

```sh-session
$ mix deps.get
```

Run `mix compile` to build both the Elixir and the C++ code.


##Usage

```elixir
iex> {:ok, srv} = ExPerHash.start_link
{:ok, #PID<0.91.0>}

iex> ExPerHash.dd_hash srv, "some/image.png"
{:ok, <<140, 173, 167, 143, 157, 141, 14, 39, 77, 9, 3, 135, 23, 49, 25, 89>>}
```

Three hash functions are available: aHash, dHash and ddHash.

[aHash](http://www.hackerfactor.com/blog/index.php?/archives/432-Looks-Like-It.html)
by dr. Neal Krawitz creates a hash based on the average of the low frequencies
of an image.

[dHash](http://www.hackerfactor.com/blog/index.php?/archives/529-Kind-of-Like-That.html)
by dr. Neal Krawitz and [David Oftedal](http://01101001.net/programming.php)
tracks gradients instead. In this variant, images are resized to 8x8 pixels
and each row wraps around to the next, with the last row wrapping around to
the first. Hash bits are set in order from left to right (most significant to
least significant).

ddHash is a double dHash, one row-wise and one column-wise.

All hash functions return `{:ok, hash}` on success, where hash is a binary. For
aHash and dHash, the hash is 64 bits (8 bytes), for ddHash it is 128 bits
(16 bytes).

On error, all functions return `{:error, {error_type, reason}`.


##License

Copyright © 2015 Ookami Kenrou \<ookamikenrou@gmail.com\>

This work is free. You can redistribute it and/or modify it under the terms of
the Do What The Fuck You Want To Public License, Version 2, as published by
Sam Hocevar. See the LICENSE file or the [WTFPL homepage](http://www.wtfpl.net)
for more details.

