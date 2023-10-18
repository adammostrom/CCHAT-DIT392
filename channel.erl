-module(channel).
-export([start/1, channel_handler/2]).

-record(channel_state, {
    name,
    clients
}).

initial_state(Channel) ->
    #channel_state{
        name = Channel,
        clients = []
    }.

start(Channel) ->
    State = initial_state(Channel),
    genserver:start(list_to_atom(Channel), State, fun channel_handler/2).

channel_handler(State, Request) ->
    case Request of
        {join, Nick, From} ->
            addToChannel(State, Nick, From);
        {leave, From} ->
            removeFromChannel(State, From);
        {message_send, Msg, From, Nick} ->
            sendMessage(State, From, Msg, Nick)
    end.

removeFromChannel(State, From) ->
    % io:format("removeFromChannel.channel.CLientList ~p~n", [State#channel_state.clients]),
    io:format("removeFromChannel.channel.from ~p~n", [From]),
    io:format("channelState ~p~n", [State]),
    NewChannelList = lists:delete(From, State#channel_state.clients),
    NewState = State#channel_state{clients = NewChannelList},
    io:format("channelState ~p~n", [NewState]),
    {reply, ok, NewState}.

addToChannel(State, Nick, From) ->
    %register(From, Nick),
    %User = {From, Nick},
    NewChannelList = [From| State#channel_state.clients],
    io:format("addToChannel.channel.NewChannelList ~p~n", [NewChannelList]),
    NewState = State#channel_state{clients = NewChannelList},
    {reply, ok, NewState}.

    sendMessage(State, From, Msg, Nick) ->
        NewList = lists:delete(From, State#channel_state.clients),
        lists:foreach(
            fun(Member) ->
                %MemberPid = getFromValue(Member),
                Member ! {request, self(), make_ref(), {message_receive, State#channel_state.name, Nick, Msg}}
            end,
            NewList),
        {reply, ok, State}.
       
    % Member ! {request, self(), make_ref(), {message_receive, State#channel_state.name, From, Msg}}
    


    getFromValue({From, _}) -> From.
    getNickValue({_, Nick}) -> Nick.
