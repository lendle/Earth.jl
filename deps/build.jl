using BinDeps

@BinDeps.setup

ver = "3.2-6"
fname = "standalone-earth-$(ver).tar.gz"

libearth = library_dependency("libearth", aliases=["libearth.so"])


provides(Sources, URI("http://www.milbo.users.sonic.net/earth/$fname"), libearth)

prefix=joinpath(BinDeps.depsdir(libearth),"usr")
provides(SimpleBuild,
    (@build_steps begin
       ChangeDirectory(joinpath(Pkg.dir("Earth"), "deps"))
        FileDownloader("http://www.milbo.users.sonic.net/earth/$fname", joinpath(".", fname))
        FileUnpacker(fname, pwd(), "standalone-earth")
        FileRule(joinpath(prefix, "lib", "libearth.so"), @build_steps begin
            `make libearth.so`
            CreateDirectory(joinpath(prefix, "lib"))
            `cp libearth.so $(prefix)/lib/`
            `make cleanbuild`
        end)
    end), libearth)

@BinDeps.install [:libearth => :libearth]
