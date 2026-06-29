import sys

with open('lib/zmanim_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# indices are 0-based
start_idx = 331  # line 332
end_idx = 427    # exclusive, line 428 (we want to replace up to line 427 inclusive)
# So we will replace lines[start_idx:end_idx] where end_idx is 427 (since line 428 is index 427)
# Wait line 428 corresponds to index 427 (since line number -1). We want to keep line 428 onward.
# So we replace lines[331:427] (since 427 is exclusive, that gives us indices 331..426 inclusive, which are lines 332..427).
# Let's verify: line 332 index 331, line 427 index 426. So slice [331:427) gives 331..426.
# Good.

new_block = [
    '  @override\n',
    '  Widget build(BuildContext context) {\n',
    '    return Scaffold(\n',
    '      appBar: PreferredSize(\n',
    '        preferredSize: Size.fromHeight(kToolbarHeight),\n',
    '        child: Container(\n',
    '          color: Theme.of(context).colorScheme.inversePrimary,\n',
    '          child: Row(\n',
    '            crossAxisAlignment: CrossAxisAlignment.stretch,\n',
    '            children: [\n',
    '              // Hamburger (leading) - 20% width -> flex 2 out of 10\n',
    '              Expanded(\n',
    '                flex: 2,\n',
    '                child: IconButton(\n',
    '                  icon: const Icon(Icons.menu),\n',
    '                  onPressed: () {\n',
    '                    // TODO: open drawer\n',
    '                  },\n',
    '                  iconSize: 24,\n',
    '                  padding: EdgeInsets.zero,\n',
    '                  constraints: BoxConstraints.expand(),\n',
    '                ),\n',
    '              ),\n',
    '              // Title - 30% width -> flex 3\n',
    '              Expanded(\n',
    '                flex: 3,\n',
    '                child: MediaQuery(\n',
    '                  data: MediaQuery.of(context).copyWith(\n',
    '                    textScaler: TextScaler.noScaling,\n',
    '                  ),\n',
    '                  child: const Center(\n',
    '                    child: Text(\\\'Zmanim\\\'),\n',
    '                  ),\n',
    '                ),\n',
    '              ),\n',
    '              // Today button - part of actions, allocate flex 2 (20%)\n',
    '              Expanded(\n',
    '                flex: 2,\n',
    '                child: MediaQuery(\n',
    '                  data: MediaQuery.of(context).copyWith(\n',
    '                    textScaler: TextScaler.noScaling,\n',
    '                  ),\n',
    '                  child: TextButton(\n',
    '                    onPressed: _goToTodayOrReload,\n',
    '                    style: TextButton.styleFrom(\n',
    '                      foregroundColor: Theme.of(context).colorScheme.onSurface,\n',
    '                      padding: EdgeInsets.zero,\n',
    '                      minimumSize: Size.zero,\n',
    '                    ),\n',
    '                    child: const Text(\\\'Today\\\'),\n',
    '                  ),\n',
    '                ),\n',
    '              ),\n',
    '              // IconButton left - flex 1 (10%)\n',
    '              Expanded(\n',
    '                flex: 1,\n',
    '                child: IconButton(\n',
    '                  icon: const Icon(Icons.chevron_left),\n',
    '                  iconSize: 24,\n',
    '                  padding: EdgeInsets.zero,\n',
    '                  constraints: BoxConstraints.expand(),\n',
    '                  onPressed: _goToPreviousDay,\n',
    '                ),\n',
    '              ),\n',
    '              // IconButton calendar - flex 1 (10%)\n',
    '              Expanded(\n',
    '                flex: 1,\n',
    '                child: IconButton(\n',
    '                  icon: const Icon(Icons.calendar_today),\n',
    '                  iconSize: 24,\n',
    '                  padding: EdgeInsets.zero,\n',
    '                  constraints: BoxConstraints.expand(),\n',
    '                  onPressed: _pickDate,\n',
    '                ),\n',
    '              ),\n',
    '              // IconButton right - flex 1 (10%)\n',
    '              Expanded(\n',
    '                flex: 1,\n',
    '                child: IconButton(\n',
    '                  icon: const Icon(Icons.chevron_right),\n',
    '                  iconSize: 24,\n',
    '                  padding: EdgeInsets.zero,\n',
    '                  constraints: BoxConstraints.expand(),\n',
    '                  onPressed: _goToNextDay,\n',
    '                ),\n',
    '              ),\n',
    '            ],\n',
    '          ),\n',
    '        ),\n',
    '      ),\n',
    '      body: _buildBody(context),\n',
    '    );\n',
    '  }\n',
]

# Replace
lines[start_idx:427] = new_block

with open('lib/zmanim_screen.dart', 'w', encoding='utf-8') as f:
    f.writelines(lines)

print('Replacement done')