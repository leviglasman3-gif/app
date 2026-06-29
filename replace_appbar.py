import re

with open('lib/zmanim_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

start_marker = '@override\n  Widget build(BuildContext context) {\n    final screenWidth = MediaQuery.of(context).size.width;\n    final isNarrow = screenWidth <= 380;'
end_marker = '  Widget _buildBody(BuildContext context) {'

start = content.find(start_marker)
end = content.find(end_marker)
print(f'Start: {start}, End: {end}', flush=True)

# New build method (no narrow/wide helpers, just the PreferredSize Row with flexes)
new_build = """  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            color: Theme.of(context).colorScheme.inversePrimary,
            child: Row(
              children: [
                // Hamburger (leading) - 20% width -> flex 2 out of 10
                Expanded(
                  flex: 2,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      // TODO: open drawer
                    },
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                // Title - 30% width -> flex 3
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.noScaling,
                      ),
                      child: const Text('Zmanim'),
                    ),
                  ),
                ),
                // Today button - part of actions, allocate flex 2 (20%)
                Expanded(
                  flex: 2,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.noScaling,
                    ),
                    child: TextButton(
                      onPressed: _goToTodayOrReload,
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Today'),
                    ),
                  ),
                ),
                // IconButton left - flex 1 (10%)
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _goToPreviousDay,
                  ),
                ),
                // IconButton calendar - flex 1 (10%)
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _pickDate,
                  ),
                ),
                // IconButton right - flex 1 (10%)
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _goToNextDay,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }
"""

new_content = content[:start] + new_build + '\n' + content[end:]
with open('lib/zmanim_screen.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)
print('Done. New file written.', flush=True)
