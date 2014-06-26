using BinDeps

@BinDeps.setup

ver = "3.2-6"
fname = "standalone-earth-$(ver).tar.gz"

libearth = library_dependency("libearth", aliases=["libearth.so"])


provides(Sources, URI("http://www.milbo.users.sonic.net/earth/$fname"), libearth)


provides(SimpleBuild,
    (@build_steps begin
       ChangeDirectory(joinpath(Pkg.dir("Earth"), "deps"))
        FileDownloader("http://www.milbo.users.sonic.net/earth/$fname", joinpath(".", fname))
        FileUnpacker(fname, pwd(), "standalone-earth")
        `make libearth.so`
    end), libearth)

@BinDeps.install [:libearth => :libearth]

# depsdir = joinpath(Pkg.dir("Earth"), "deps")

# cd(depsdir)
# run(download_cmd("http://www.milbo.users.sonic.net/earth/$fname",
#                  joinpath(depsdir, fname)))
# run(unpack_cmd(fname, ".", ".gz", ".tar"))
# run(`make libearth.so`)
