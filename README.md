# Enron Email Graph
Creates a network that relates Enron employees constructed from their public email communication.

![Screenshot](https://raw.githubusercontent.com/NathanielWroblewski/enron_email_graph/master/screenshot.png)

[Enron email data](https://www.cs.cmu.edu/~./enron/) publicly released as part of FERC’s Western Energy Markets investigation.

### Redactions ###

Note that I am using the redacted Enron email dataset, and I also culled only emails sent from and sent to email addresses with an `enron.com` domain.  I did this for performance reasons, as it cut down the number of nodes from 41,000 to 12,000.
