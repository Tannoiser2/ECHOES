extends RefCounted
## Centralised seeded RNG (spec v0.2 §5, appendix A10).
##
## Nothing else in the codebase is allowed to call randi()/randf() or
## Array.shuffle(): those read the global RNG and would break the determinism
## requirement in §18.3. Every random decision goes through this service.
##
## The RNG position is persisted as a *draw counter*, not as the engine's raw
## 64-bit state word, so a save round-trip cannot lose precision through JSON.
## Restoring re-seeds and fast-forwards; see docs/DECISIONS.md D-004.

var _rng := RandomNumberGenerator.new()
var _seed: int = 0
var _draws: int = 0


func _init(p_seed: int = 0) -> void:
	reseed(p_seed)


## Reset to `p_seed` and replay `p_draws` values, so the service lands exactly
## where it was when the save was written.
func reseed(p_seed: int, p_draws: int = 0) -> void:
	_seed = p_seed
	_rng.seed = p_seed
	_draws = 0
	for _i in range(p_draws):
		_next()


func get_seed() -> int:
	return _seed


## Number of values consumed so far. This is what goes into world_state.rng_state.
func get_draws() -> int:
	return _draws


## Deliberately NOT named randi_range: GDScript resolves unqualified calls to
## @GlobalScope built-ins before methods of the enclosing class, so a method
## with that name would silently never be called and every "seeded" draw would
## come from the global RNG instead.
func range_int(from: int, to: int) -> int:
	if from >= to:
		return from
	var span: int = to - from + 1
	return from + int(_next() % span)


## 1d6 for the Confluence World Factor (§12.2 F).
func roll_d6() -> int:
	return self.range_int(1, 6)


## Deterministic Fisher-Yates. Returns a new Array; the input is untouched.
func shuffle(source: Array) -> Array:
	var out: Array = source.duplicate()
	var i: int = out.size() - 1
	while i > 0:
		var j: int = self.range_int(0, i)
		var tmp: Variant = out[i]
		out[i] = out[j]
		out[j] = tmp
		i -= 1
	return out


## Pick one element deterministically. Returns null on an empty array.
func pick(source: Array) -> Variant:
	if source.is_empty():
		return null
	return source[self.range_int(0, source.size() - 1)]


func _next() -> int:
	_draws += 1
	# randi() is uniform over the full 32-bit range; the modulo bias it leaves at
	# our range sizes (<= 64) is far below anything the game can observe, and the
	# sequence is what matters for reproducibility.
	return _rng.randi()
