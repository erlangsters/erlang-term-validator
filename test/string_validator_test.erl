%%
%% Copyright (c) 2023, Byteplug LLC.
%%
%% This source file is part of the Erlang Term Validator project which is
%% released under the MIT license. Please refer to the LICENSE.txt file that
%% can be found at the root of the project directory.
%%
%% Written by Jonathan De Wachter <jonathan.dewachter@byteplug.io>, July 2023
%%
-module(string_validator_test).
-include_lib("eunit/include/eunit.hrl").

string_validator_test() ->
    valid = term_validator:validate("Hello world!", string),
    valid = term_validator:validate("Hello world!", {string, []}),

    Format = {string, []},
    {invalid, not_string} = term_validator:validate(false, Format),
    {invalid, not_string} = term_validator:validate(true, Format),
    {invalid, not_string} = term_validator:validate(42, Format),
    valid = term_validator:validate([], Format),
    {invalid, not_string} = term_validator:validate({}, Format),
    {invalid, not_string} = term_validator:validate(#{}, Format),

    ok.

string_validator_length_test() ->
    % Test with simple syntax.
    Format1 = {string, [{length, {4, 8}}]},

    {invalid, {too_short, must_be_greater_or_equal_to, 4}} =
        term_validator:validate("123", Format1),

    valid = term_validator:validate("1234", Format1),
    valid = term_validator:validate("12345678", Format1),

    {invalid, {too_long, must_be_less_or_equal_to, 8}} =
        term_validator:validate("123456789", Format1),

    % Test with extended syntax.
    Format2 = {string, [{length, {{4, inclusive}, {8, inclusive}}}]},

    {invalid, {too_short, must_be_greater_or_equal_to, 4}} =
        term_validator:validate("123", Format2),

    valid = term_validator:validate("1234", Format2),
    valid = term_validator:validate("12345678", Format2),

    {invalid, {too_long, must_be_less_or_equal_to, 8}} =
        term_validator:validate("123456789", Format2),

    ok.

string_validator_length_min_test() ->
    Format1 = {string, [{length, {4, no_max}}]},
    Format2 = {string, [{length, {{4, inclusive}, no_max}}]},
    Format3 = {string, [{length, {{4, exclusive}, no_max}}]},

    {invalid, {too_short, must_be_greater_or_equal_to, 4}} = term_validator:validate("123", Format1),
    valid = term_validator:validate("1234", Format1),

    {invalid, {too_short, must_be_greater_or_equal_to, 4}} = term_validator:validate("123", Format2),
    valid = term_validator:validate("1234", Format2),

    {invalid, {too_short, must_be_strictly_greater_than, 4}} = term_validator:validate("123", Format3),
    {invalid, {too_short, must_be_strictly_greater_than, 4}} = term_validator:validate("1234", Format3),

    % Test 'no_min' value.
    Format4 = {string, [{length, {no_min, 8}}]},
    valid = term_validator:validate("", Format4),

    ok.

string_validator_length_max_test() ->
    Format1 = {string, [{length, {no_min, 8}}]},
    Format2 = {string, [{length, {no_min, {8, inclusive}}}]},
    Format3 = {string, [{length, {no_min, {8, exclusive}}}]},

    {invalid, {too_long, must_be_less_or_equal_to, 8}} = term_validator:validate("123456789", Format1),
    valid = term_validator:validate("12345678", Format1),

    {invalid, {too_long, must_be_less_or_equal_to, 8}} = term_validator:validate("123456789", Format2),
    valid = term_validator:validate("12345678", Format2),

    {invalid, {too_long, must_be_strictly_less_than, 8}} = term_validator:validate("123456789", Format3),
    {invalid, {too_long, must_be_strictly_less_than, 8}} = term_validator:validate("12345678", Format3),

    % Test 'no_max' value.
    Format4 = {string, [{length, {4, no_max}}]},
    valid = term_validator:validate("123456789", Format4),

    ok.

string_validator_alphabet_ascii_test() ->
    Format = {string, [{alphabet, ascii}]},

    valid = term_validator:validate("Hello world!", Format),
    {invalid, {wrong_character, 233, position, 8}} =
        term_validator:validate("Hello Téïtéïa!", Format),
    {invalid, {wrong_character, 128512, position, 14}} =
        term_validator:validate("Hello world! 😀", Format),

    % Test shorthand syntax.
    valid = term_validator:validate("Hello world!", {string, [ascii]}),
    {invalid, {wrong_character, 233, position, 8}} =
        term_validator:validate("Hello Téïtéïa!", {string, [ascii]}),
    {invalid, {wrong_character, 128512, position, 14}} =
        term_validator:validate("Hello world! 😀", {string, [ascii]}),

    ok.

string_validator_alphabet_latin1_test() ->
    Format = {string, [{alphabet, latin1}]},

    valid = term_validator:validate("Hello world!", Format),
    valid = term_validator:validate("Hello Téïtéïa!", Format),
    {invalid, {wrong_character, 128512, position, 14}} =
        term_validator:validate("Hello world! 😀", Format),

    % Test shorthand syntax.
    valid = term_validator:validate("Hello world!", {string, [latin1]}),
    valid = term_validator:validate("Hello world!", {string, [latin1]}),
    {invalid, {wrong_character, 128512, position, 14}} =
        term_validator:validate("Hello world! 😀", {string, [latin1]}),

    ok.

string_validator_alphabet_custom_test() ->
    Alphabet = "abcdefghijklmnopqrstuvwxyz ",
    Format = {string, [{alphabet, Alphabet}]},

    {invalid, {wrong_character, 72, position, 1}} =
        term_validator:validate("Hello world!", Format),
    valid = term_validator:validate("hello world", Format),

    ok.

string_validator_pattern_test() ->
    Pattern = "^[a-z]+$",
    {invalid, {pattern_mismatch, Pattern}} = term_validator:validate(
        "Hello world!",
        {string, [{pattern, Pattern}]}
    ),

    valid = term_validator:validate(
        "Hello world!",
        {string, [{pattern, "^Hello"}]}
    ),

    ok.
