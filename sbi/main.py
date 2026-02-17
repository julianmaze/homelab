import logging
import yfinance as yf

TICKERS_FILE_PATH = "./tickers.txt"

def main():
    log.info("Opening " + TICKERS_FILE_PATH)
    with open(TICKERS_FILE_PATH, 'r') as f:
        tickers = f.read()
    log.info(tickers)

    log.info("Gathering financial info for each ticker")
    for t in tickers:
        dat = yf.Ticker(t)
        dat.info

    log.info("Add ticker data to the database")

