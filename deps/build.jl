using BinDeps

@BinDeps.setup

ver = "3.2-6"
fname = "standalone-earth-$(ver).tar.gz"

libearth = library_dependency("libearth", aliases=["libearth.so"])


provides(Sources, URI("http://www.milbo.users.sonic.net/earth/$fname"), libearth)


provides(SimpleBuild,
    (@build_steps begin
        FileDownloader("http://www.milbo.users.sonic.net/earth/$fname", joinpath(".", fname))
        FileUnpacker(fname, pwd(), "standalone-earth")
        `make`
        # @build_steps begin
        #     ChangeDirectory(srcdir)
        #     `cat $patchdir/CoinMP-emptyproblem.patch` |> `patch -N -p1`
        #     `./configure --prefix=$prefix --enable-dependency-linking`
        #     `make install`
        # end
    end), libearth)

@BinDeps.install [:libearth => :libearth]

# depsdir = joinpath(Pkg.dir("Earth"), "deps")

# cd(depsdir)
# run(download_cmd("http://www.milbo.users.sonic.net/earth/$fname",
#                  joinpath(depsdir, fname)))
# run(unpack_cmd(fname, ".", ".gz", ".tar"))
# run(`make libearth.so`)
