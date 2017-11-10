package uk.me.csquared.ratpacktest;

/**
 * Created by colin on 30/05/2016.
 */
import ratpack.server.RatpackServer;

public class Main {
    public static void main(String[] args) throws Exception{
        RatpackServer.start(server -> server
                .handlers(chain -> chain
                        .get(ctx -> ctx.render("Hello DivX"))
                        .get(":name", ctx -> ctx.render("Hello " +
                                ctx.getPathTokens().get("name!") + "!"))
                )
        );

    }
}


