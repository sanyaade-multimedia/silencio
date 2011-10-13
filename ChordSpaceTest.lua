require "Silencio"
ChordSpace = require("ChordSpace")
--ChordSpace = require("Chords")
local matrix = require("matrix")

local printPass = false
local failExits = true
local exitAfterFailureCount = 3
local failureCount = 0
local printOP = false
local printChordSpaceGroup = false

print([[

U N I T   T E S T S   F O R   C H O R D S P A C E

We generate all chords in R and test the consistency of the formulas for
identifying (iseE) and generating (eE) each of the equivalence classes (E)
O, P, T, I, OP, OPT, OPI, and OPTI with respect to their representative or
"normal" fundamental domains.

If the formulas for the fundamental domains identify or produce duplicates,
then the duplicates must be removed or accounted for in the tests. This
could happen e.g. if Chord:iseE() identifies more than one chord as the
equivalent, but Chord:eE() sends all equivalent chords to one element of that
class.

In addition, 3-dimensional graphics of iseE(R) and eE(R) for trichords must
look correct for OP, OPI, OPT, and OPTI.

]])

for n = 0, 12 do
	local f = ChordSpace.factorial(n)
	print(string.format('%2d factorial is: %9d.', n, f))
end
print('')

print('How does operator % behave?')
for pitch = -24, 23, 1 do
    local pc = pitch % ChordSpace.OCTAVE
    print(string.format('%9.4f = %9.4f %% ChordSpace.OCTAVE', pc, pitch))
end
print('')

if printOP == true then
    print('Printing all of OP...')
    local ops = ChordSpace.allOfEquivalenceClass(3, 'OP')
    print(string.format('There are %d trichords in OP.', #ops))
    for index, op in pairs(ops) do
        print(string.format('Chord      %4d:\n%s\n', index, op:information()))
    end
    print('')
end

--local chord = Chord:new{4, 7, 11}
local chord = Chord:new{0, 4, 7, 10}
for index, permutation in ipairs(chord:permutations()) do
    print(string.format('permutation: %s', tostring(permutation)))
end
for index, voicing in ipairs(chord:voicings()) do
    local et = voicing:et()
    print(string.format('voicing: %s  et: %s  span: %9.4f  iseV: %s', tostring(voicing), tostring(et), et:maximumInterval(), tostring(et:iseV())))
end
print(chord:information())

function pass(message)
    if printPass then
        print()
        print('PASSED:', message)
        print()
    end
end

function fail(message)
    print('========================================================================')
    print('FAILED:', message)
    print('========================================================================')
    failureCount = failureCount + 1
    if failExits and (failureCount > exitAfterFailureCount) then
        os.exit()
    end
end

function result(expression, message)
    if expression then
        pass(message)
    else
        fail(message)
    end
end

----[[

print('Equivalence class OPTI:')
local ops = ChordSpace.allOfEquivalenceClass(4, 'OP')
local optis = {}
for index, chord in pairs(ops) do
    opti = chord:eOPTI()
    table.insert(optis, opti)
end
optis = ChordSpace.sortedSet(optis)
for index, opti in pairs(optis) do
    local transposition = math.ceil(opti[1]) - opti[1]
    local optti = opti:T(transposition)
    print(index, tostring(opti), transposition, tostring(optti), tostring(opti:eOPTTI()))
end

local chordSpaceGroup = ChordSpaceGroup:new()
chordSpaceGroup:initialize(4, 60)
if printChordSpaceGroup then
    chordSpaceGroup:list()
    print()
end
print('Equivalence class OPTTI:')
for index, chord in pairs(chordSpaceGroup.optisForIndexes) do
    print(index, tostring(chord))
end

local GbM7 = ChordSpace.chordsForNames['GbM7']
print('GbM7:')
print(GbM7:information())
local P, I, T, V = chordSpaceGroup:fromChord(GbM7)
print('PITV', P, I, T, V)
print(string.format('GbM7:             P: %d  I: %s  T: %s  V: %s', P, I, T, V))
GbM7[2] = GbM7[2] + 12
GbM7[4] = GbM7[4] + 24
print('GbM7 revoiced:')
print(GbM7:information())
P, I, T, V = chordSpaceGroup:fromChord(GbM7)
print(string.format('GbM7 revoiced:    P: %d  I: %s  T: %s  V: %s', P, I, T, V))

local shouldBeGbM7 = chordSpaceGroup:toChord(P, I, T, V)
print('shouldBeGbM7:')
print(shouldBeGbM7:information())
P, I, T, V = chordSpaceGroup:fromChord(shouldBeGbM7)
print(string.format('shouldBeGbM7:     P: %d  I: %s  T: %s  V: %s', P, I, T, V))
result(shouldBeIofGbM7 == IofGbM7, 'ChordSpaceGroup: GbM7 must be the same from and to PITV')

local IofGbM7 = ChordSpace.chordsForNames['GbM7']:I():eOP()
print('IofGbM7:')
print(IofGbM7:information())
P, I, T, V = chordSpaceGroup:fromChord(IofGbM7)
print(string.format('IofGbM7:          P: %d  I: %s  T: %s  V: %s', P, I, T, V))
IofGbM7[2] = IofGbM7[2] + 12
IofGbM7[4] = IofGbM7[4] + 24
print('IofGbM7 revoiced:')
print(IofGbM7:information())
P, I, T, V = chordSpaceGroup:fromChord(IofGbM7)
print(string.format('IofGbM7 revoiced: P: %d  I: %s  T: %s  V: %s', P, I, T, V))

local shouldBeIofGbM7 = chordSpaceGroup:toChord(P, I, T, V)
print('shouldBeIofGbM7:')
print(shouldBeIofGbM7:information())
P, I, T, V = chordSpaceGroup:fromChord(shouldBeIofGbM7)
print(string.format('shouldBeIofGbM7:  P: %d  I: %s  T: %s  V: %s', P, I, T, V))
result(shouldBeIofGbM7 == IofGbM7, 'ChordSpaceGroup: IofGbM7 must be the same from and to PITV')
print('')

G7 = ChordSpace.chordsForNames['G7']
print(G7:information())
P, I, T, V = chordSpaceGroup:fromChord(G7)
for T = 0, 11 do
    chord = chordSpaceGroup:toChord(P, I, T, V)
    print(chord:information())
    chord = chordSpaceGroup:toChord(P, I+1, T, V)
    print(chord:information())
end

for voiceCount = 3, 4 do

    if true then

    passes = true
    chordSpaceGroup = ChordSpaceGroup:new()
    chordSpaceGroup:initialize(voiceCount, 48)
    chordSpaceGroup:list()
    for P = 0, chordSpaceGroup.countP - 1 do
        for I = 0, 1 do
            for T = 0, ChordSpace.OCTAVE - 1 do
                for V = 0, chordSpaceGroup.countV - 1 do
                    local fromPITV = chordSpaceGroup:toChord(P, I, T, V)
                    print(string.format("toChord  (P: %f  I: %f  T: %f  V: %f) = %s", P, I, T, V, tostring(fromPITV)))
                    local p, i, t, v = chordSpaceGroup:fromChord(fromPITV)
                    local frompitv = chordSpaceGroup:toChord(p, i, t, v)
                    print(string.format("fromChord(P: %f  I: %f  T: %f  V: %f) = %s", p, i, t, v, tostring(frompitv)))
                    if (fromPITV ~= frompitv) or (p ~= P) or (i ~= I) or (t ~= T) or (v ~= V) then
                        --print(string.format("toChord  (P: %f  I: %f  T: %f  V: %f) = %s", P, I, T, V, tostring(fromPITV)))
                        --print(string.format("fromChord(P: %f  I: %f  T: %f  V: %f) = %s", p, i, t, v, tostring(frompitv)))
                        passes = false
                        result(passes, string.format('All of P, I, T, V for %d voices must translate back and forth.', voiceCount))
                    end
                    print('')
                end
            end
        end
    end
    result(passes, string.format('All of P, I, T, V for %d voices must translate back and forth.', voiceCount))
    end
end
--]]

local range = ChordSpace.OCTAVE + 1

--[[
Consistency is tested as follows for a set of chords in R for 2 through 12
voices, for each equivalence class whether simple (O) or compound (OP):

chord:eE():iseE() == true
-- Skip if duplicate iseE(): (chord:iseE() == true) => (chord:eE() == chord)
not (chord:iseE() == true) => not (chord:eE() == chord)
(chord:eE() == chord) => (chord:iseE() == true)
not (chord:eE() == chord) => not (chord:iseE() == true)

Additionally, for the compound equivalence classes, chord:isE() on the l.h.s.
will imply AND of each chord:iseE() for the constituent simple equivalent
classes on the r.h.s, and the same with the sides switched.

iseOP <=> iseO and iseP
iseOPT <=> iseOP and iseO and iseP and iseT and iseV
iseOPI <=> iseOP and iseO and iseP and iseI
iseOPTI <=> iseOPT and iseOPI and iseOP and iseO and iseP and iseT and iseI and iseV
]]
function testEquivalence(equivalence, chord, iseE, eE)
    local equivalent = eE(chord)
    if (iseE(equivalent) == true) then
        pass(string.format('chord:e%s():ise%s == true\nChord:\n%s\nEquivalent:\n%s', equivalence, equivalence, tostring(chord), tostring(equivalent)))
    else
        fail(string.format('chord:e%s():ise%s == true\nChord:\n%s\nEquivalent:\n%s', equivalence, equivalence, chord:information(), equivalent:information()))
    end
    if (iseE(chord) == true) then
        if (equivalent == chord) then
            pass(string.format('(chord:ise%s() == true) => (chord:e%s == chord)\nChord:\n%s\nEquivalent:\n%s', equivalence, equivalence, tostring(chord), tostring(equivalent)))
        else
            fail(string.format('(chord:ise%s() == true) => (chord:e%s == chord)\nChord:\n%s\nEquivalent:\n%s', equivalence, equivalence, chord:information(), equivalent:information()))
        end
    end
    if not (iseE(chord) == true) then
        if not (equivalent == chord) then
            pass(string.format('not (chord:ise%s() == true) => not (chord:e%s == chord)\nChord:\n%s\nEquivalent:\n%s', equivalence, equivalence, tostring(chord), tostring(equivalent)))
        else
            fail(string.format('not (chord:ise%s() == true) => not (chord:e%s == chord)\nChord:\n%s\nEquivalent:\n%s', equivalence, equivalence, chord:information(), equivalent:information()))
        end
    end
    if (equivalent == chord) then
        if (iseE(chord) == true) then
            pass(string.format('(equivalent == chord) => (chord:ise%s() == true)\nChord:\n%s\nEquivalent:\n%s', equivalence, equivalence, tostring(chord), tostring(equivalent)))
        else
            fail(string.format('(equivalent == chord) => (chord:ise%s() == true)\nChord:\n%s\nEquivalent:\n%s', equivalence, equivalence, chord:information(), equivalent:information()))
        end
    end
    if not (equivalent == chord) then
        if not (iseE(chord) == true) then
            pass(string.format('not (equivalent == chord) => not (chord:ise%s() == true)\nChord:\n%s\nEquivalent:\n%s', equivalence, tostring(chord), tostring(equivalent)))
        else
            fail(string.format('not (equivalent == chord) => not (chord:ise%s() == true)\nChord:%s\nEquivalent:%s', equivalence, chord:information(), equivalent:information()))
        end
    end
end

function testCompoundEquivalence(equivalence, chord, iseE, otherIseEs)
    local otherIseEsN = 0
    for index, otherIseE in ipairs(otherIseEs) do
        if (otherIseE(chord) == true) then
            otherIseEsN = otherIseEsN + 1
        end
    end
    if (iseE(chord) == true) then
        if otherIseEsN == #otherIseEs then
            pass(string.format('%s: compound equivalence for:\n%s', equivalence, tostring(chord)))
        else
            fail(string.format('%s: missing component equivalence for:\n%s', equivalence, chord:information()))
        end
    end
    if not (iseE(chord) == true) then
        if otherIseEsN == #otherIseEs then
            fail(string.format('%s: false compound equivalence for:\n%s', equivalence, chord:information()))
        else
            pass(string.format('%s: compound equivalence for:\n%s', equivalence, tostring(chord)))
        end
    end
end

local function testEquivalences(voices)
    local chord = ChordSpace.iterator(voices, -range)
    while ChordSpace.next(chord, -range, range, 1) do
        testEquivalence('O',    chord, Chord.iseO,    chord.eO)
        testEquivalence('P',    chord, Chord.iseP,    chord.eP)
        testEquivalence('T',    chord, Chord.iseT,    chord.eT)
        testEquivalence('I',    chord, Chord.iseI,    chord.eI)
        testEquivalence('V',    chord, Chord.iseV,    chord.eV)
        testEquivalence('OP',   chord, Chord.iseOP,   chord.eOP)
        testEquivalence('OPT',  chord, Chord.iseOPT,  chord.eOPT)
        testEquivalence('OPI',  chord, Chord.iseOPI,  chord.eOPI)
        testEquivalence('OPTI', chord, Chord.iseOPTI, chord.eOPTI)
        testCompoundEquivalence('OP', chord, Chord.iseOP, {Chord.iseO, Chord.iseP})
    end
end

for voices = 2, 12 do
    print(string.format('\nTESTING CHORDS OF %2d VOICES...\n', voices))
    testEquivalences(voices)
end

local a = Chord:new{3, 3, 6}
local b = Chord:new{3, 3, 6}
print(a:__hash())
print(b:__hash())
result(a == b, 'Chord hash codes for identical values must be identical.')

chords = {}
table.insert(chords, Chord:new{-3, 0, 0})
table.insert(chords, Chord:new{0, 0, 0})
table.insert(chords, Chord:new{0, -3, 0})
table.insert(chords, Chord:new{0, 0, -3})
volume1 = ChordSpace.volumeSquared(chords)
print('volume: ' .. tostring(volume1))
chords = {}
table.insert(chords, Chord:new{-3, 0, 0, 0})
table.insert(chords, Chord:new{0, 0, 0, 0})
table.insert(chords, Chord:new{3, -3, 0, 0})
table.insert(chords, Chord:new{0, 0, -3, 0})
volume2 = ChordSpace.volumeSquared(chords)
print('volume: ' .. tostring(volume2))
result(math.abs(volume1) == math.abs(volume2), "Volumes of same simplex in space and in subspace must be equal.")
for i = 3, 12 do
    print(string.format('CHORDS OF %d VOICES...', i))
    local chord = Chord:new()
    chord:resize(i)
    local maximallyEven = chord:maximallyEven()
    print(string.format('maximallyEven for %2d voices: %s', i, tostring(maximallyEven)))
    local cyclicalSimplex = chord:cyclicalSimplex(ChordSpace.OCTAVE)
    print('cyclical region:\n' .. matrix:new(cyclicalSimplex):tostring())
    local homogeneous = ChordSpace.homogeneousSimplex(cyclicalSimplex)
    print('homogeneous:\n' .. homogeneous:tostring())
    local invariant = ChordSpace.invariantSimplex(homogeneous)
    print('invariant:\n' .. invariant:tostring())
    local transposed = invariant:transpose()
    print('transposed:\n' .. transposed:tostring())
    local squared = matrix.mul(transposed, invariant)
    print('squared:\n' .. squared:tostring())
    for j = 1, #cyclicalSimplex do
        local point = cyclicalSimplex[j]
        print(tostring(point) .. '  BC: ' .. tostring(ChordSpace.barycentricCoordinates(point, cyclicalSimplex)))
    end
    local epSimplex = chord:epSimplex(ChordSpace.OCTAVE)
    for j = 1, #epSimplex do
        local point = epSimplex[j]
        print(tostring(point) .. '  BC: ' .. tostring(ChordSpace.barycentricCoordinates(point, epSimplex)))
    end
    local targetCoordinates = chord:origin()
    if ChordSpace.backwards then
        targetCoordinates[1] = 1
    else
        targetCoordinates[#targetCoordinates] = 1
    end
    local coordinates = ChordSpace.barycentricCoordinates(chord, cyclicalSimplex)
    if coordinates == targetCoordinates then
        passes = true
    else
        passes = false
    end
    result(passes, string.format('Barycentric coordinates of %s are %s must be %s.', tostring(chord), tostring(coordinates), tostring(targetCoordinates)))
    local outsideChord = chord:clone()
    outsideChord[1] = -100
    local coordinates = ChordSpace.barycentricCoordinates(outsideChord, cyclicalSimplex)
    result(true, string.format('Barycentric coordinates of %s are %s.', tostring(outsideChord), tostring(coordinates)))
end
-- One and only one of the cyclical permutations of a chord must be in the normal region.
-- If the chord is equal to the cyclical permutation that is in the normal region, it is
-- in the representative fundamental domain of voicing equivalence.
local chordTypes = {'CM', 'Cm', 'C7', 'CM7', 'Cm7', 'Co7', 'C9', 'CM9', 'Cm9'}
for k, chordType in pairs(chordTypes) do
    local chord = ChordSpace.chordsForNames[chordType]:et()
    local epSimplex = chord:epSimplex()
    for j = 1, #epSimplex do
        local point = epSimplex[j]
        print(string.format('Normal region %2d: %s  layer: %6.2f', j, tostring(point), tostring(point:sum())))
    end
    local permutations = chord:cyclicalPermutations()
    local insideCount = 0
    for i, permutation in pairs(permutations) do
        permutation = permutation
        chord = permutation
        local maximallyEven = chord:maximallyEven()
        print(string.format('maximallyEven for %2d voices: %s', i, tostring(maximallyEven)))
        local epSimplex = chord:epSimplex(ChordSpace.OCTAVE)
        print('normal region:\n' .. matrix:new(epSimplex):tostring())
        local homogeneous = ChordSpace.homogeneousSimplex(epSimplex)
        print('homogeneous:\n' .. homogeneous:tostring())
        local invariant = ChordSpace.invariantSimplex(homogeneous)
        print('invariant:\n' .. invariant:tostring())
        local transposed = invariant:transpose()
        print('transposed:\n' .. transposed:tostring())
        local squared = matrix.mul(transposed, invariant)
        print('squared:\n' .. squared:tostring())
        local isInside = permutation:isInSimplex(epSimplex)
        if isInside then
            insideCount = insideCount + 1
        end
        print(string.format('%5s permutation %d: %s  inside: %s', chordType, i, tostring(permutation), tostring(isInside)))
    end
    result(insideCount == 1, "One and only one of the cyclical permutations of a chord must be in the normal region: actually inside: " .. tostring(insideCount))
end
os.exit(0)

function iseOPIeOPI(voiceCount)
    dump = dump or false
    local chords = ChordSpace.allChordsInRange(voiceCount, ChordSpace.OCTAVE)
    local passes = true
    local chord = nil
    local opi = nil
    for i = 1, #chords do
        chord = chords[i]
        if chord:iseOP() then
            opi = chord:eOPI()
            if chord == opi then
                if chord:iseOPI() == false or opi:iseOPI() == false then
                    passes = false
                    break
                end
            else
                if chord:iseOPI() == opi:iseOPI() then
                    passes = false
                    break
                end
                if chord:iseOPI() and chord ~= opi then
                    passes = false
                    break
                end
                if opi:iseOPI() and chord == opi then
                    passes = false
                    break
                end
            end
        end
    end
    if passes == false then
        print(chord:information())
        print(opi:information())
    end
    result(passes, string.format('eOPI must equate to iseOPI for %d voices.', voiceCount))
end

function printVoicings(chord)
    print(chord:information())
    local voicings = chord:voicings()
    for i, voicing in ipairs(voicings) do
        print(string.format('voicing: %d %s iseV %s %f', i, tostring(voicing), tostring(voicing:iseV(ChordSpace.OCTAVE)), voicing:distanceToUnisonDiagonal()))
        print(string.format('eOP:     %d %s', i, tostring(voicing:eOP())))
        print(string.format('et:      %d %s', i, tostring(voicing:et())))
        print(string.format('eop:     %d $s', i, tostring(voicing:eop())))
        print(string.format('eopt:    %d %s', i, tostring(voicing:eopt())))
        print(string.format('eOPI:    %d %s', i, tostring(voicing:eOPI())))
        print(string.format('eOPT:    %d %s iseOPT %s', i, tostring(voicing:eOPT()), tostring(voicing:iseOPT())))
    end
end

print('TESTING CHORD SPACE GROUPS...')
local chordSpaceGroup = ChordSpaceGroup:new()
chordSpaceGroup:initialize(4, 60)
chordSpaceGroup:list()

local GbM7 = ChordSpace.chordsForNames['GbM7']
print('GbM7:')
print(GbM7:information())
local P, I, T, V = chordSpaceGroup:fromChord(GbM7)
print(string.format('GbM7:             P: %d  I: %s  T: %s  V: %s', P, I, T, V))
GbM7[2] = GbM7[2] + 12
GbM7[4] = GbM7[4] + 24
print('GbM7 revoiced:')
print(GbM7:information())
P, I, T, V = chordSpaceGroup:fromChord(GbM7)
print(string.format('GbM7 revoiced:    P: %d  I: %s  T: %s  V: %s', P, I, T, V))

local shouldBeGbM7 = chordSpaceGroup:toChord(P, I, T, V)
print('shouldBeGbM7:')
print(shouldBeGbM7:information())
P, I, T, V = chordSpaceGroup:fromChord(shouldBeGbM7)
print(string.format('shouldBeGbM7:     P: %d  I: %s  T: %s  V: %s', P, I, T, V))
result(shouldBeIofGbM7 == IofGbM7, 'ChordSpaceGroup: GbM7 must be the same from and to PITV')

local IofGbM7 = ChordSpace.chordsForNames['GbM7']:I():eOP()
print('IofGbM7:')
print(IofGbM7:information())
P, I, T, V = chordSpaceGroup:fromChord(IofGbM7)
print(string.format('IofGbM7:          P: %d  I: %s  T: %s  V: %s', P, I, T, V))
IofGbM7[2] = IofGbM7[2] + 12
IofGbM7[4] = IofGbM7[4] + 24
print('IofGbM7 revoiced:')
print(IofGbM7:information())
P, I, T, V = chordSpaceGroup:fromChord(IofGbM7)
print(string.format('IofGbM7 revoiced: P: %d  I: %s  T: %s  V: %s', P, I, T, V))

local shouldBeIofGbM7 = chordSpaceGroup:toChord(P, I, T, V)
print('shouldBeIofGbM7:')
print(shouldBeIofGbM7:information())
P, I, T, V = chordSpaceGroup:fromChord(shouldBeIofGbM7)
print(string.format('shouldBeIofGbM7:  P: %d  I: %s  T: %s  V: %s', P, I, T, V))
result(shouldBeIofGbM7 == IofGbM7, 'ChordSpaceGroup: IofGbM7 must be the same from and to PITV')
print('')

G7 = ChordSpace.chordsForNames['G7']
print(G7:information())
P, I, T, V = chordSpaceGroup:fromChord(G7)
for T = 0, 11 do
    chord = chordSpaceGroup:toChord(P, I, T, V)
    print(chord:information())
    chord = chordSpaceGroup:toChord(P, I+1, T, V)
    print(chord:information())
end

for voiceCount = 3, 4 do

    if false then

    passes = true
    chordSpaceGroup = ChordSpaceGroup:new()
    chordSpaceGroup:initialize(voiceCount, 48)
    chordSpaceGroup:list()
    for P = 0, chordSpaceGroup.countP - 1 do
        for I = 0, 1 do
            for T = 0, ChordSpace.OCTAVE - 1 do
                for V = 0, chordSpaceGroup.countV - 1 do
                    local fromPITV = chordSpaceGroup:toChord(P, I, T, V)
                    print(string.format("toChord  (P: %f  I: %f  T: %f  V: %f) = %s", P, I, T, V, tostring(fromPITV)))
                    local p, i, t, v = chordSpaceGroup:fromChord(fromPITV)
                    local frompitv = chordSpaceGroup:toChord(p, i, t, v)
                    print(string.format("fromChord(P: %f  I: %f  T: %f  V: %f) = %s", p, i, t, v, tostring(frompitv)))
                    if (fromPITV ~= frompitv) or (p ~= P) or (i ~= I) or (t ~= T) or (v ~= V) then
                        --print(string.format("toChord  (P: %f  I: %f  T: %f  V: %f) = %s", P, I, T, V, tostring(fromPITV)))
                        --print(string.format("fromChord(P: %f  I: %f  T: %f  V: %f) = %s", p, i, t, v, tostring(frompitv)))
                        passes = false
                        result(passes, string.format('All of P, I, T, V for %d voices must translate back and forth.', voiceCount))
                    end
                    print('')
                end
            end
        end
    end
    result(passes, string.format('All of P, I, T, V for %d voices must translate back and forth.', voiceCount))
    print('All of OP')
    local chords = ChordSpace.allOfEquivalenceClass(voiceCount, 'OP')
    for index, chord in pairs(chords) do
        print(string.format('OP: %5d', index))
        print(chord:information())
        if chord:iseOP() == false then
            fail(string.format('Each chord in OP must return iseOP true for %d voices.', voiceCount))
        end
        print('')
    end
    pass(string.format('Each chord in OP must return iseOP true for %d voices.', voiceCount))

    end

    print('All of OPT')
    local chords = ChordSpace.allOfEquivalenceClass(voiceCount, 'OPT')
    for index, chord in pairs(chords) do
        print(string.format('OPT: %5d', index))
        print(chord:information())
        if chord:iseOPT() == false then
            fail(string.format('Each chord in OPT must return iseOPT true for %d voices.', voiceCount))
        end
        if chord:eOPT() ~= chord then
            fail(string.format('Each chord in OPT must be eOPT for %d voices.', voiceCount))
        end
        print('')
    end
    pass(string.format('Each chord in OPT must return iseOPT true for %d voices.', voiceCount))
    pass(string.format('Each chord in OPT must be eOPT for %d voices.', voiceCount))

    print('All of OPI')
    local chords = ChordSpace.allOfEquivalenceClass(voiceCount, 'OPI')
    for index, chord in pairs(chords) do
        print(string.format('OPI: %5d', index))
        print(chord:information())
        if chord:iseOPI() == false then
            fail(string.format('Each chord in OPI must return iseOPI true for %d voices.', voiceCount))
        end
        if chord:eOPI() ~= chord then
            fail(string.format('Each chord in OPI must be eOPI for %d voices.', voiceCount))
        end
        print('')
    end
    pass(string.format('Each chord in OPI must return iseOPI true for %d voices.', voiceCount))
    pass(string.format('Each chord in OPI must be eOPI for %d voices.', voiceCount))

    print('All of OPTI')
    local chords = ChordSpace.allOfEquivalenceClass(voiceCount, 'OPTI')
    for index, chord in pairs(chords) do
        print(string.format('OPTI: %5d', index))
        print(chord:information())
        if chord:iseOPTI() == false then
            fail(string.format('Each chord in OPTI must return iseOPTI true for %d voices.', voiceCount))
        end
        if chord:eOPTI() ~= chord then
            print('Normal:' .. chord:information())
            print('eOPTI: ' .. chord:eOPTI():information())
            fail(string.format('Each chord in OPTI must be eOPTI for %d voices.', voiceCount))
        end
        print('')
    end
    pass(string.format('Each chord in OPTI must return iseOPTI true for %d voices.', voiceCount))
    pass(string.format('Each chord in OPTI must be eOPTI for %d voices.', voiceCount))

    local ops = ChordSpace.allOfEquivalenceClass(voiceCount, 'OP')
    local flatset ={}
    for key, chord in pairs(ops) do
        local inversion = chord:I():eOP()
        local reinversion = inversion:I():eOP()
        local flat = chord:flatP()
        local reflection = chord:reflect(flat)
        local opreflection = reflection:eOP()
        local rereflection = reflection:reflect(flat):eOP()
        print(string.format('chord %5d:  %s', key, tostring(chord)))
        print(string.format('inversion:    %s', tostring(inversion)))
        print(string.format('reinversion:  %s', tostring(reinversion)))
        print(string.format('flat:         %s', tostring(flat)))
        print(string.format('reflection:   %s', tostring(reflection)))
        print(string.format('opreflection: %s', tostring(opreflection)))
        print(string.format('rereflection: %s', tostring(rereflection)))
        print(string.format('is flat:      %s', tostring(chord:isFlatP())))
        print(string.format('iseOPI:       %s', tostring(chord:iseOPI())))
        print(string.format('iseOPI(I):    %s', tostring(inversion:iseOPI())))
        print(string.format('eOPI:         %s', tostring(chord:eOPI())))
        print(string.format('eOPI(I):      %s\n', tostring(inversion:eOPI())))
        if not (inversion == opreflection) then
            fail(string.format('Reflection in the inversion flat must be the same as inversion in the origin for %d voices.', voiceCount))
        end
        if not(reinversion == rereflection) then
            fail(string.format('Re-inversion must be the same as re-reflection for %d voices.', voiceCount))
        end
        if not(reinversion == chord) then
            fail(string.format('Re-inversion and re-reflection must be the same as the original chord for %d voices.', voiceCount))
        end
    end
    pass(string.format('Reflection in the inversion flat must be the same as inversion in the origin for %d voices.', voiceCount))
    pass(string.format('Re-inversion must be the same as re-reflection for %d voices.', voiceCount))
    pass(string.format('Re-inversion and re-reflection must be the same as the original chord for %d voices.', voiceCount))
    pass(string.format('Re-inversion and re-reflection must be the same as the original chord for %d voies.', voiceCount))
    print(string.format('All chords in inversion flat for %d voices:', voiceCount))
    flats = ChordSpace.flatsP(3, ChordSpace.OCTAVE)
    for key, flat in pairs(flats) do
        print(string.format('flat: %s', tostring(flat)))
    end
    iseOPIeOPI(voiceCount)
    passes = true
    local chord
    local inverseop
    for i = 1, #ops do
        chord = ops[i]
        inverseop = chord:I():eOP()
        if chord:iseOPI() == true and inverseop:iseOPI() == true then
            if chord ~= inverseop then
                passes = false
                break
            end
        end
        if chord:iseOPI() == false and inverseop:iseOPI() == false then
            passes = false
            break
        end
    end
    if not passes then
        print(chord)
        print(inverseop)
    end
    result(passes, string.format('Chord/Inverse must be, if not a fixed point, one inside/one outside the representative fundamental domain of inversional equivalence for %d voices.', voiceCount))
end

--os.exit()

local c3333 = Chord:new{3,3,3,3}
printVoicings(c3333)
print('')
local chord = ChordSpace.chordsForNames['CM9']
printVoicings(chord)
print('')

--os.exit()

print('c3333', c3333:information())
local ic3333 = c3333:I():eOP()
print('ic3333', ic3333:information())

local Caug = ChordSpace.chordsForNames['C+']
local areeV = 0
for t = 0, 11 do
    local chord = Caug:T(t):eOP()
    print('C+ t', t, chord:information())
    print(chord:iseV(ChordSpace.OCTAVE))
    if chord:iseV(ChordSpace.OCTAVE) then
        areeV = areeV + 1
    end
end
print('areeV:', areeV)
print('')

local CM = ChordSpace.chordsForNames['CM']
local areeV = 0
for t = 0, 11 do
    local chord = CM:T(t):eOP()
    print('CM t', t, chord:information())
    print(chord:iseV(ChordSpace.OCTAVE))
    if chord:iseV(ChordSpace.OCTAVE) then
        areeV = areeV + 1
    end
end
print('areeV:', areeV)
print('')

local CM7 = ChordSpace.chordsForNames['CM7']
local areeV = 0
for t = 0, 11 do
    local chord = CM7:T(t):eOP()
    print('CM7 t', t, chord:information())
    print(chord:iseV(ChordSpace.OCTAVE))
    if chord:iseV(ChordSpace.OCTAVE) then
        areeV = areeV + 1
    end
end
print('areeV:', areeV)
print('')

local CM9 = ChordSpace.chordsForNames['CM9']
local areeV = 0
for t = 0, 11 do
    local chord = CM9:T(t):eOP()
    print('CM9 t', t, chord:information())
    print(chord:iseV(ChordSpace.OCTAVE))
    if chord:iseV(ChordSpace.OCTAVE) then
        areeV = areeV + 1
    end
end
print('areeV:', areeV)
print('')

verbose = true

for voices = 2, 6 do
    local passes = true
    local dummy, ops = ChordSpace.allOfEquivalenceClass(voices, 'OP')
    local op = nil
    local opt = nil
    local opti = nil
    local opti_i = nil
    for i = 1, #ops do
        op = ops[i]
        opt = op:eOPT()
        opt_i = opt:I()
        opt_i_op = opt_i:eOP()
        opt_i_opt = opt_i:eOPT()
        opti = op:eOPTI()
        opti_i = opti:I()
        opti_i_op = opti_i:eOP()
        opti_i_opt = opti_i:eOPT()
        if (op == opti) or (op == opti_i) then
            if op ~= opt then
                passes = false
                print('If it is OPTI or OPTI:I:OPT it must be OPT.')
                break
            end
        end
        if op == opt then
            if not ((op == opti) or (op == opti_i_opt)) then
                ChordSpace.bing = true
                passes = false
                print('If it is OPT it must be either OPTI or OPTI:I:OPT.')
                local voicings = op:voicings()
                for key, voicing in pairs(voicings) do
                    print(tostring(voicing:et()) .. '  iseV: ' .. tostring(voicing:iseV(ChordSpace.OCTAVE)) .. ' To unisons: ' .. tostring(voicing:et():distanceToUnisonDiagonal()))
                end
                break
            end
        end
    end
    if passes == false then
        print('op:        ' .. tostring(op))
        print('opt:       ' .. tostring(opt))
        print('opt_i:     ' .. tostring(opt_i))
        print('opt_i_op:  ' .. tostring(opt_i_op))
        print('opt_i_opt: ' .. tostring(opt_i_opt))
        print('opti:      ' .. tostring(opti))
        print('opti_i:    ' .. tostring(opti_i))
        print('opti_i_op: ' .. tostring(opti_i_op))
        print('opti_i_opt:' .. tostring(opti_i_opt))
        result(passes, string.format('OPTI U OPTI:I():eOPT() == OPT for %d voices.', voices))
    end
end

test('a = Chord:new()')
result('a', a)
test('a = Chord:new(); a:resize(3)')
result('a', a, 'a.channel[3]', a.channel[3])
result('a[1]', a[1])
test('a[1] = 2')
result('a', a)
test('b = Chord:new()')
result('b', b)
test('b:resize(3)')
result('b', b)
test('equals = (a == b)')
result('a', a, 'b', b, 'equals', equals)
test('b[1] = 2', b)
test('equals = (a == b)')
result('a', a, 'b', b, 'equals', equals)
test('c = Chord:new{3, 2, 1}')
result('c', c)
test('s = c:eP()')
result('c', c, 's', s)
test('lt = (a < c)')
result('a', a, 'c', c, 'lt', lt)
test('lt = (c < a)')
result('a', a, 'c', c, 'lt', lt)
test('m = a:min()')
result('a', a, 'm', m)
test('m = a:max()')
result('a', a, 'm', m)
test('d = c:clone()')
result('c', c, 'd', d)
test('n = c:count(2)')
result('c', c, 'n', n)
test('n = a:count(0)')
result('a', a, 'n', n)
test('n = c:sum()')
result('c', c, 'n', n)
test('n = a:sum()')
result('a', a, 'n', n)
test('s = a:eP()')result('a', a, 's', s)
print('')
test('c = Chord:new{0, 4, 7}; voicings = c:voicings()')
for i = 1, #voicings do
    voicing = voicings[i]
    print('voicing:', voicing, 'voicing:iseI():', voicing:iseI(), 'voicing:iseV(ChordSpace.OCTAVE)', voicing:iseV(ChordSpace.OCTAVE))
end
print('')
test('c = Chord:new{0, 4, 7, 10, 14}; voicings = c:voicings()')
for i = 1, #voicings do
    voicing = voicings[i]
    print('voicing:', voicing, 'voicing:iseI():', voicing:iseI(), 'voicing:iseV(ChordSpace.OCTAVE)', voicing:iseV(ChordSpace.OCTAVE))
end
print('')
test('o = Orbifold:new()')
result('o', o, 'o.N', o.N, 'o.R', o.R, 'o.octaves', o.octaves, 'o.NR', o.NR)
test('v = o:voiceleading(c, a)')
result('c', c, 'a', a, 'v', v)
test('e = o:T(c, 3)')
result('c', c, 'e', e)
test('c1 = Chord:new{19, 13, 14}; c1o = c1:eO(); c1op = c1:eO():eP()')
result('c1', c1, 'c1o', c1o, 'c1op', c1op)
test('c = Chord:new{0, 4, 7}; d = c:I(6, 12);')
result('c', c, 'd', d)
test('c = Chord:new{0, 4, 7}; d = o:I(c, 6);')
result('c', c, 'd', d)
test('c = Chord:new{4, 4, 4}; d = c:I(5, 12);')
result('c', c, 'd', d)
test('c = Chord:new{4, 4, 4}; d = o:I(c, 5);')
result('c', c, 'd', d)
test('c = Chord:new{24, 7, 16}; t = c:eOP(c)')
result('c', c, 't', t)
test('c = Chord:new{0, 4, 7}; d = c:cycle(1);')
result('c', c, 'd', d)
test('c = Chord:new{0, 4, 7}; d = c:cycle(-1);')
result('c', c, 'd', d)
test('c = Chord:new{0, 4, 7}; d = c:V();')
result('c', c, 'd', d)
test('c = Chord:new{0, 16, 7}; d = c:voicings();')
result('c', c, 'd', d)
for i, voicing in ipairs(d) do
    result('voicing', voicing)
end
test('s = o:smoothness(c, b)')
result('c', c, 'b', b, 's', s)
test('s = o:smoothness(c, c)')
result('c', c, 'c', c, 's', s)
test('a = Chord:new{5, 5, 5}; b = Chord:new{19, 19, 19}; p = o:parallelFifth(a, b)')
result('a', a, 'b', b, 'p', p)
test('a = Chord:new{5, 5, 5}; b = Chord:new{12, 12, 12}; p = o:parallelFifth(a, b)')
result('a', a, 'b', b, 'p', p)
test('s = o:smoother(a, b, c, false)')
result('s', s, 'a', a, 'c', c, 'b', b)
test('s = o:smoother(a, b, c, true)')
result('s', s, 'a', a, 'c', c, 'b', b)
test('s = o:simpler(a, b, c, false)')
result('s', s, 'a', a, 'c', c, 'b', b)
test('s = o:simpler(a, b, c, true)')
result('s', s, 'a', a, 'c', c, 'b', b)
test('z = a:eT()')
result('a', a, 'z', z, 'z:sum()', z:sum())
test('z = c:eT()')
result('c', c, 'z', z, 'z:sum()', z:sum())
test('d = Chord:new{5, 8, 1}; z = d:eT()')
result('d', d, 'z', z, 'z:sum()', z:sum())
test('vs = o:voicings(d)')
vs = o:voicings(d)
for i = 1, #vs do
    result('i', i, 'vs[i]', vs[i])
end
print('')
for i = 1, 12 do
    snippet = string.format('cn = Chord:new{0, 4, 7}; cnt = cn:T(%d); copt = o:eOPT(cnt); copti = o:eOPTI(cnt);', i)
    test(snippet)
    result('cn', cn, 'cnt', cnt, 'copt', copt, 'copti', copti)
end
print('')
test('o:setOctaves(2)')
test('vs = o:voicings(d)')
vs = o:voicings(d)
for i = 1, #vs do
    result('i', i, 'vs[i]', vs[i])
end
test('o:setOctaves(1)')
test('z = o:eOPI(d)')
result('d', d, 'z', z)
test('z = o:eOPTI(d)')
result('d', d, 'z', z)
test('layer = d:sum()')
result('d', d, 'layer', layer)
test('s = d:sum()')
result('d', d, 's', s)
test('no = Chord:new{7, 4, 0}; inorder = no:iseP();')
result('no', no, 'inorder', inorder)
test('inside = o:eRP(c)')
result('inside', inside, 'c', c)
test('z = Chord:new{0, 4, 7}; p = o:nrP(z)')
result('z', z, 'p', p)
test('l = o:nrL(z)')
result('z', z, 'l', l)
test('r = o:nrR(z)')
result('z', z, 'r', r)
test('d = o:nrD(z)')
result('z', z, 'd', d)
test('k = o:K(z)')
result('z', z, 'k', k, 'note', 'same pcs as R, different order')
test('c0 = Chord:new{0, 4, 7}; c5 = o:T(c0, 5); tform = o:Tform(c0, c5, 1)')
result('c0', c0, 'c5', c5, 'tform', tform)
test('c0 = Chord:new{0, 4, 7}; c5 = o:T(c0, 5); iform= o:Iform(c0, c5, 1)')
result('c0', c0, 'c5', c5, 'iform', iform)
test('c0 = Chord:new{0, 4, 7}; c5 = o:I(c0, 5); iform= o:Iform(c0, c5, 1)')
result('c0', c0, 'c5', c5, 'iform', iform)
test('m = o:nrP(z); q = o:Q(z, 1, z, 1)')
result('z', z, 'm', m, 'q', q)
test('q = o:Q(z, -1, z, 1)')
result('z', z, 'q', q)
print('')
test('k = o:K(z)')
result('z', z, 'k', k)
test('r = o:nrR(z)')
result('z', z, 'r', r)
test('m7 = Chord:new{0, 3, 7, 10}; k7 = o:K(m7)')
result('m7', m7, 'k7', k7)
print('')
test('p = o:nrP(z)')
result('z', z, 'p', p)
test('l = o:nrL(z)')
result('z', z, 'l', l)
test('d = o:nrD(z)')
result('z', z, 'd', d)
print('')
test('m = Chord:new{0, 3, 7}; m1 = o:nrR(c):eOP()')
result('m', m, 'm1', m1)
print('')
for i = 0, 12 do
    test(string.format('q = o:Q(z,  %s, z, 1)', i))
    result('z', z, 'q', q)
    test(string.format('q = o:Q(z, -%s, m, 1)', i))
    result('z', z, 'q', q)
    test(string.format('q = o:Q(z,  %s, z, 1)', i))
    result('z', z, 'q', q)
    test(string.format('q = o:Q(z, -%s, m, 1)', i))
    result('z', z, 'q', q)
end
print('')
test('voicings = o:voicings(c)')
result('c', c)
for i, voicing in ipairs(voicings) do
    result('voicing', voicing, 'voicing:eO()', voicing:eO())
end
print('')
