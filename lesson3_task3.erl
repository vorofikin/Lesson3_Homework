-module(lesson3_task3).
-export([split/2]).

split(BinText, Delimiter) ->
  split(BinText, Delimiter, [], <<>>).

split(BinText, Delimiter, Acc, CurrentPart) ->
  DelimSize = byte_size(list_to_binary(Delimiter)),
  BinDelim = list_to_binary(Delimiter),
  case BinText of
    <<BinDelim:DelimSize/binary, Rest/binary>> -> split(Rest, Delimiter, [CurrentPart | Acc], <<>>);
    <<Char, Rest/binary>> -> split(Rest, Delimiter, Acc, <<CurrentPart/binary, Char/utf8>>);
    <<>> -> lists:reverse([CurrentPart | Acc])
  end.
