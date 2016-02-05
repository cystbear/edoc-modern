-module(edoc_modern).
-export([
	run/2
]).

-include_lib("edoc/include/edoc_doclet.hrl").

-spec run(#doclet_gen{} | #doclet_toc{}, #context{}) -> ok.
run(#doclet_gen{sources = Sources, app = App}, Context) ->
	gen(Sources, App, Context);
run(#doclet_toc{paths = Paths}, Context) ->
	io:format("TOC~npaths=~p~ncontext=~p~n", [Paths, Context]).
	%toc(Paths, Context).

%% @private
gen(Sources, App, #context{dir = Dir, env = Env, opts = Options}) ->
	ModulesMetadata = lists:foldl(fun ({Module, Filename, Filedir}, ModulesMetadata) ->
		Name = atom_to_list(Module) ++ ".html",
		{Metadata, Html} = module(App, Module, filename:join(Filedir, Filename), Env, Options),
		edoc_lib:write_file(Html, Dir, Name, [{encoding, utf8}]),
		[Metadata | ModulesMetadata]
	end, [], Sources),
	write_metadata(Dir, #{modules => ModulesMetadata}),
	copy_assets(filename:join(Dir, "assets")).

%% @private
write_metadata(Dir, Metadata) ->
	MetadataStr = ["sidebarNodes=", jsx:encode(Metadata), ";"],
	edoc_lib:write_file(MetadataStr, Dir, "metadata.js", [{encoding, utf8}]).

%% @private
copy_assets(ToDir) ->
	FromDir = code:priv_dir(?MODULE),
	ok = copy_asset(FromDir, ToDir, "app.css"),
	ok = copy_asset(FromDir, ToDir, "app.js").

%% @private
copy_asset(FromDir, ToDir, Name) ->
	From = filename:join(FromDir, Name),
	To = filename:join(ToDir, Name),
	ok = filelib:ensure_dir(To),
	edoc_lib:copy_file(From, To).

%% @private
module(App, Module, Path, Env, Options) ->
	Title = title(App, Module),
	{_Module, Doc} = edoc:get_doc(Path, Env, Options),
	Metadata = #{id => Module, title => Module, functions => [], types => []},
	Xml = page(Title, navigation(edoc:layout(Doc, [{layout, edoc_modern_layout} | Options]))),
	Html = xmerl:export_simple(Xml, edoc_modern_html5, []),
	{Metadata, Html}.

%% @private
title(?NO_APP, Module) ->
	io_lib:fwrite("~s", [Module]);
title(App, Module) ->
	io_lib:fwrite("~s – ~s", [Module, App]).

%% @private
navigation(Content) ->
	[{'div', [{class, "main"}], [
		{button, [{class, "sidebar-toggle"}], [{i, [{class, "icon-menu"}], []}]},
		{section, [{class, "sidebar"}], [
			{button, [{class, "sidebar-toggle"}], [{i, [{class, "icon-menu"}], []}]},
			{ul, [{class, "sidebar-listNav"}], [
				{li, [
					{a, [{id, "modules-list"}, {href, "#full-list"}], ["Modules"]}
				]}
			]},
			{ul, [{id, "full-list"}, {class, "sidebar-fullList"}], []},
			{'div', [{class, "sidebar-noResults"}], []}
		]},
		{section, [{class, "content"}], [
			{'div', [{id, "content"}, {class, "content-inner"}], Content}
		]}
	]}].

%% @private
page(Title, Body) ->
	[{html, [
		{head, [
			meta([{charset, "utf-8"}]),
			meta([{'http-equiv', "x-ua-compatible"}, {content, "ie=edge"}]),
			meta([{name, "viewport"}, {content, "width=device-width, initial-scale=1.0"}]),
			meta([{name, "generator"}, {content, "EDoc"}]),
			{title, [Title]},
			{link, [{rel, "stylesheet"}, {href, "assets/app.css"}], []}
		]},
		{body, [],
			Body ++
			[
				{script, [{src, "metadata.js"}], []},
				{script, [{src, "assets/app.js"}], []}
			]
		}
	]}].

%% @private
meta(Attributes) ->
	{meta, Attributes, []}.
