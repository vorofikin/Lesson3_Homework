-module(lesson3_task1).
-export([first_word/1]).

first_word(BinText) ->
  first_word(BinText, <<>>).

first_word(<<>>, Acc) ->
  Acc;

first_word(<<Char, Rest/binary>>, Acc) when Char =/= 32 ->
  first_word(Rest, <<Acc/binary, Char>>);

first_word(<<_Char, _/binary>>, Acc) when byte_size(Acc) > 0 ->
  Acc.
