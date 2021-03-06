%% -------------------------------------------------------------------
%%
%% Copyright (c) 2015 Carlos Gonzalez Florido.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

%% @private NkSIP main supervisor
-module(nksip_sup).
-author('Carlos Gonzalez <carlosj.gf@gmail.com>').

-behaviour(supervisor).

% -export([start_sipapp/2, stop_sipapp/1]).
-export([init/1, start_link/0]).

-include("nksip.hrl").

% %% @private Starts a new Service's process
% start_sipapp(SrvId, Args) ->
%     Spec = {SrvId,
%                 {nksip_sipapp_sup, start_link, [SrvId, Args]},
%                 permanent,
%                 infinity,
%                 supervisor,
%                 [nksip_sipapp_sup]},
%     case supervisor:start_child(nksip_sipapp_sup, Spec) of
%         {ok, _SupPid} -> ok;
%         {error, {Error, _}} -> {error, Error};
%         {error, Error} -> {error, Error}
%     end.


% %% @private Stops a Service's core
% stop_sipapp(SrvId) ->
%     case supervisor:terminate_child(nksip_sipapp_sup, SrvId) of
%         ok -> ok = supervisor:delete_child(nksip_sipapp_sup, SrvId);
%         {error, _} -> error
%     end.


%% @private
start_link() ->
    ChildsSpec = [
        % {nksip_dns,
        %     {nksip_dns, start_link, []},
        %     permanent,
        %     5000,
        %     worker,
        %     [nksip_dns]},
        % {nksip_webserver_sup,
        %     {nksip_webserver_sup, start_link, []},
        %     permanent,
        %     infinity,
        %     supervisor,
        %     [nksip_webserver_sup]},
        % {nksip_webserver,
        %     {nksip_webserver, start_link, []},
        %     permanent,
        %     5000,
        %     worker,
        %     [nksip_webserver]}
        % {nksip_sipapp_sup,
        %     {?MODULE, start_sipapps_sup, []},
        %     permanent,
        %     infinity,
        %     supervisor,
        %     [?MODULE]}
     ] 
     ++
     [get_call_routers(N) || N <- lists:seq(0, nksip_config_cache:msg_routers()-1)],
  supervisor:start_link({local, ?MODULE}, ?MODULE, {{one_for_one, 10, 60}, ChildsSpec}).

% %% @private
% start_sipapps_sup() ->
%     supervisor:start_link({local, nksip_sipapp_sup}, 
%                             ?MODULE, {{one_for_one, 10, 60}, []}).

%% @private
init(ChildSpecs) ->
    {ok, ChildSpecs}.


%% @private
get_call_routers(Pos) ->
    Name = nksip_router:pos2name(Pos),
    {Name,
        {nksip_router, start_link, [Pos, Name]},
        permanent,
        5000,
        worker,
        [nksip_call]}.

