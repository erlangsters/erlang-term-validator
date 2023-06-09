%%
%% Copyright (c) 2023, Byteplug LLC.
%%
%% This source file is part of the Erlang Term Validator project which is
%% released under the MIT license. Please refer to the LICENSE.txt file that
%% can be found at the root of the project directory.
%%
%% Written by Jonathan De Wachter <jonathan.dewachter@byteplug.io>, March 2023
%%
-module(atom_validator).
-behaviour(term_validator).

-export([mandatory_options/0]).
-export([options/0]).
-export([pre_validate/3]).
-export([validate/3]).
-export([post_validate/2]).

mandatory_options() -> [].
options() -> [one_of, allow_string].

pre_validate(Term, _Options, _Validators) when is_atom(Term) ->
    {valid, Term};
pre_validate(Term, Options, _Validators) when is_list(Term) ->
    case lists:member(allow_string, Options) of
        true ->
            {valid, list_to_atom(Term)};
        false ->
            {invalid, not_atom}
    end;
pre_validate(_Term, _Options, _Validators) ->
    {invalid, not_atom}.

validate(Term, {one_of, Items}, _Validators) ->
    case lists:member(Term, Items) of
        true ->
            {valid, Term};
        false ->
            {invalid, {not_one_of, Items}}
    end;
validate(Term, allow_string, _Validators) ->
    {valid, Term}.

post_validate(_Term, _Validators) ->
    valid.
