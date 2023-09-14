-module(lesson3_task4).

-export([decode/2]).

-define(SINGLE_QUOTE, "'").
-define(COMMA, ",").
-define(OPEN_CURLY_BRACE, "{").
-define(CLOSE_CURLY_BRACE, "}").
-define(COLON, ":").
-define(OPEN_SQUARE_BRACKET, "[").
-define(CLOSE_SQUARE_BRACKET, "]").
-define(NEW_LINE, "\n").
-define(TRUE, "true").
-define(FALSE, "false").
-define(IS_SPACE(Char),
  Char == 10;
  Char == 32;
  Char == "\n"
).
-define(EMPTY, "").

decode(Json, map) ->
  decode_map(Json, maps:new());
decode(Json, proplist) ->
  decode_proplist(Json, []).

decode_proplist(<<?COMMA, Rest/binary>>, PropList) ->
  {Key, Value, Rest1} = tokenize(Rest, <<>>, <<>>, proplist),
  decode_proplist(Rest1, [{Key, Value} | PropList]);
decode_proplist(<<?OPEN_CURLY_BRACE, Rest/binary>>, PropList) ->
  {Key, Value, Rest1} = tokenize(Rest, <<>>, <<>>, proplist),
  decode_proplist(Rest1, [{Key, Value} | PropList]);
decode_proplist(<<Char, Rest/binary>>, PropList) when ?IS_SPACE(Char) ->
  decode_proplist(Rest, PropList);
decode_proplist(<<?CLOSE_CURLY_BRACE>>, PropList) ->
  lists:reverse(PropList);
decode_proplist(<<?CLOSE_CURLY_BRACE, Rest/binary>>, PropList) ->
  case delete(Rest) of
    <<?EMPTY>> -> lists:reverse(PropList);
    Rest1 -> {lists:reverse(PropList), Rest1}
  end.

decode_map(<<?COMMA, Rest/binary>>, Map) ->
  {Key, Value, Rest1} = tokenize(Rest, <<>>, <<>>, map),
  decode_map(Rest1, maps:put(Key, Value, Map));
decode_map(<<?OPEN_CURLY_BRACE, Rest/binary>>, Map) ->
  {Key, Value, Rest1} = tokenize(Rest, <<>>, <<>>, map),
  decode_map(Rest1, maps:put(Key, Value, Map));
decode_map(<<Char, Rest/binary>>, Map) when ?IS_SPACE(Char) ->
  decode_map(Rest, Map);
decode_map(<<?CLOSE_CURLY_BRACE>>, Map) ->
  Map;
decode_map(<<?CLOSE_CURLY_BRACE, Rest/binary>>, Map) ->
  case delete(Rest) of
    <<?EMPTY>> -> Map;
    Rest1 -> {Map, Rest1}
  end.

tokenize(<<?SINGLE_QUOTE, Rest/binary>>, <<>>, <<>> = Value, Flag) ->
  {Key, Rest1} = tokenize_name(Rest, <<>>),
  tokenize(Rest1, Key, Value, Flag);
tokenize(<<?SINGLE_QUOTE, Rest/binary>>, Key, <<>>, _) ->
  {Value, Rest1} = tokenize_name(Rest, <<>>),
  {Key, Value, Rest1};
tokenize(<<?COLON, Rest/binary>>, Key, Value, Flag) ->
  tokenize(Rest, Key, Value, Flag);
tokenize(<<?OPEN_SQUARE_BRACKET, Rest/binary>>, Key, <<>>, Flag) ->
  {Value, Rest1} = tokenize_list(Rest, [], Flag),
  {Key, Value, Rest1};
tokenize(<<Char, Rest/binary>>, Key, Value, Flag) when ?IS_SPACE(Char) ->
  tokenize(Rest, Key, Value, Flag);
tokenize(<<?TRUE , Rest/binary>>, Key, <<>>, _) ->
  {Key, true, Rest};
tokenize(<<?FALSE , Rest/binary>>, Key, <<>>, _) ->
  {Key, false, Rest};
tokenize(Rest, Key, <<>>, _) ->
  {Value, Rest1} = tokenize_number(Rest, <<>>),
  {Key, Value, Rest1}.

tokenize_list(<<?OPEN_CURLY_BRACE, _/binary>> = Rest, List, Flag) ->
  {Value, Rest1} =
    case Flag of
      map -> decode_map(Rest, maps:new());
      proplist -> decode_proplist(Rest, [])
    end,
  tokenize_list(Rest1, [Value | List], Flag);
tokenize_list(<<?SINGLE_QUOTE, Rest/binary>>, List, Flag) ->
  {Name, Rest1} = tokenize_name(Rest, <<>>),
  tokenize_list(Rest1, [Name | List], Flag);
tokenize_list(<<?COMMA, Rest/binary>>, List, Flag) ->
  tokenize_list(Rest, List, Flag);
tokenize_list(<<?CLOSE_SQUARE_BRACKET, Rest/binary>>, List, _) ->
  {lists:reverse(List), Rest};
tokenize_list(<<Char, Rest/binary>>, List, Flag) when ?IS_SPACE(Char) ->
  tokenize_list(Rest, List, Flag).

tokenize_name(<<?SINGLE_QUOTE, Rest/binary>>, Name) ->
  {Name, Rest};
tokenize_name(<<Char, Rest/binary>>, Name)->
  tokenize_name(Rest, <<Name/binary, Char>>).

tokenize_number(<<?COMMA, _/binary>> = Rest, Number) ->
  {binary_to_integer(Number), Rest};
tokenize_number(<<Char:1/binary, Rest/binary>>, Number) ->
  tokenize_number(Rest, <<Number/binary, Char/binary>>).

delete(<<Char, Rest/binary>>) when ?IS_SPACE(Char) ->
  delete(Rest);
delete(Rest) ->
  Rest.
