:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_header)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_multipart_plugin)).
:- use_module(library(http/http_authenticate)).
:- use_module(library(http/http_unix_daemon)).

server(Port) :-
    http_server(http_dispatch, [port(Port),workers(1)]).

:- http_handler(/,index,[method(get)]).
:- http_handler(root(upload),upload,[method(post)]).
:- http_handler(root(Path),static(Path),[method(get)]).

auth(Request) :-
    Realm = 'Files Adrianistan',
    (
        string_codes("123456789",Password),
        member(authorization(Header),Request),http_authorization_data(Header,basic(aarroyoc,Password)) -> true
        ;
        throw(http_reply(authorise(basic, Realm)))
    ).

static(Path,Request) :-
    string_concat('data/',Path,RealPath),
    atom_string(AtomPath,RealPath),
    http_reply_file(AtomPath,[],Request).


index(Request) :-
    auth(Request),
    phrase(
        index_html,
        TokenHTML,
        []    
    ),
    format('Content-Type: text/html~n~n'),
    print_html(TokenHTML).

index_html -->
    html([
        head([
            title('Files Adrianistán'),
            meta(charset=utf8)   
        ]),
        body([
            h1('Files Adrianistan'),
            p('Usa el formulario para subir un archivo, si se ha subido correctamente te redirigirá a la URL que puedes usar para compartir'),
            form([action='/upload',method=post,enctype='multipart/form-data'],[
                input([type=file,name=file]),
                input([type=submit,value='Subir fichero'])
            ])  
        ])
    ]).

upload(Request) :-
    multipart_post_request(Request), !,
    http_read_data(Request, Parts,
                   [ on_filename(save_file)
                   ]),
    memberchk(file=file(FileName, _Saved), Parts),
    http_redirect(moved,root(FileName),Request).

upload(_Request) :-
    throw(http_reply(bad_request(bad_file_upload))).

multipart_post_request(Request) :-
    memberchk(method(post), Request),
    memberchk(content_type(ContentType), Request),
    http_parse_header_value(
        content_type, ContentType,
        media(multipart/'form-data', _)).

:- public save_file/3.

save_file(In, file(FileName, FileOut), Options) :-
    option(filename(FileName), Options),
    string_concat('data/',FileName,FileOut),
    setup_call_cleanup(
        open(FileOut,write,Stream,[encoding(octet)]),
        copy_stream_data(In, Stream),
        close(Stream)).

run :-
	%server(2345),
    http_daemon([port(2345),fork(false)]).

:- run.
