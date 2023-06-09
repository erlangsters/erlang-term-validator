%%
%% Copyright (c) 2023, Byteplug LLC.
%%
%% This source file is part of the Erlang Term Validator project which is
%% released under the MIT license. Please refer to the LICENSE.txt file that
%% can be found at the root of the project directory.
%%
%% Written by Jonathan De Wachter <jonathan.dewachter@byteplug.io>, March 2023
%%
-module(bool_validator).
-behaviour(term_validator).

-export([mandatory_options/0]).
-export([options/0]).
-export([pre_validate/3]).
-export([validate/3]).
-export([post_validate/2]).

mandatory_options() -> [].
options() -> [allow_number].

pre_validate(true, _Options, _Validators) ->
    {valid, true};
pre_validate(false, _Options, _Validators) ->
    {valid, false};
pre_validate(Term, Options, _Validators) ->
    case lists:member(allow_number, Options) of
        true ->
            {valid, Term};
        false ->
            {invalid, not_bool}
    end.

validate(Term, _Option, _Validators) ->
    {valid, Term}.

post_validate(_Term, _Validators) ->
    valid.
