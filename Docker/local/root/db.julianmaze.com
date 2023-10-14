$ORIGIN julianmaze.com.
@               86400 IN SOA   @  root (
                            1999010100 ; serial
                                10800 ; refresh (3 hours)
                                    900 ; retry (15 minutes)
                                604800 ; expire (1 week)
                                86400 ; minimum (1 day)
                                )
home            3600  IN A     10.50.25.55