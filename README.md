# Deckside

A swim meet and practice timer I built for the competitive youth swim group I coach. I use it on deck every week, at practices and at meets.

**Live app:** https://magnificent-dusk-065bb2.netlify.app

## The problem

At a swim meet, a coach is juggling a long heat sheet, dozens of swimmers, a stopwatch, and a clipboard of notes, all at the same time. Existing tools either cost money, need a laptop, or don't work when the pool has bad Wi-Fi. I wanted one app on my phone that handles all of it.

## Features

- **Heat sheet import:** load a meet's heat sheet PDF and the app pulls out just my swimmers, in swim order
- **Up Next / On Deck view** so I always know who is about to race
- **Multi-lane timing with splits:** time several swimmers at once from a phone
- **Board display:** the phone does the timing while a computer or TV shows the live board
- **Best times, qualifying times, and team records,** with time drops highlighted after each swim
- **Relays and seeding** from swimmers' best times
- **Practice mode** with attendance tracking
- **DQ tracking and per-swim notes** for feedback after the race
- **Works offline** as an installable app (PWA), so it keeps working on deck with no signal
- **Optional cloud sync** through Supabase so data carries across devices

## Built With

- HTML, CSS, and JavaScript (no frameworks, no build step)
- PDF.js for reading heat sheets
- Supabase for optional sync
- Service worker and web app manifest for offline use
- Netlify for hosting

## Privacy

All swimmer names in this repo and in the screenshots are made up. Real roster data is entered on the device and never stored in the code.
