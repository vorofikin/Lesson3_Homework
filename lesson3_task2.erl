-module(lesson3_task2).

-export([words/1]).

words(BinText) ->
  words(BinText, [], <<>>).

words(<<>>, [], Acc) ->
  lists:reverse([Acc]);
words(<<>>, WordsAcc, Acc) when byte_size(Acc) > 0 ->
  lists:reverse([Acc | WordsAcc]);
words(<<Char, Rest/binary>>, [], Acc) when Char =/= 32 ->
  words(Rest, [], <<Acc/binary, Char>>);
words(<<Char, Rest/binary>>, WordsAcc, Acc) when Char =/= 32 ->
  words(Rest, WordsAcc, <<Acc/binary, Char>>);
words(<<Char, Rest/binary>>, WordsAcc, Acc) when Char == 32, byte_size(Acc) > 0 ->
  words(Rest, [Acc | WordsAcc], <<>>);
words(<<Char, Rest/binary>>, WordsAcc, Acc) when Char == 32, byte_size(Acc) == 0 ->
  words(Rest, WordsAcc, <<>>).
