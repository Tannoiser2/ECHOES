extends RefCounted
## SeatDecider's `io`, wired to a terminal: lines to stdout, answers from stdin.
##
## An empty answer means "you decide" and hands that one choice to the policy.
## That is also what makes a piped script work: Godot returns the same empty
## string for a bare Enter and for end-of-input, so there is no way to tell them
## apart - and no need to. Once the answers run out every remaining prompt reads
## empty, takes the default, and the policy finishes the Chronicle. An earlier
## version tried to detect EOF and latch itself off, which meant a player who
## accepted a single default was locked out of their own game.

func say(text: String) -> void:
	print(text)


## `subjects` says what each choice is about (a Region, so far). A terminal has
## nowhere to put that, so it takes the argument and ignores it: the numbered
## list is already the whole map a terminal has.
func choose(prompt: String, labels: Array, _subjects: Array = []) -> int:
	for i in range(labels.size()):
		# A label may carry a second line - what a card does, under what it is
		# worth. Indented to the text, or the numbered list stops looking like one.
		print("   %2d) %s" % [i + 1, str(labels[i]).replace("\n", "\n       ")])
	printraw("%s [invio = lascia decidere alla policy] " % prompt)
	var answer: String = OS.read_string_from_stdin(1024).strip_edges()
	if answer == "" or not answer.is_valid_int():
		return -1
	return answer.to_int() - 1
