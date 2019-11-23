/*
 * TSM - Symbol Table Tests
 *
 * Copyright (c) 2012-2013 David Herrmann <dh.herrmann@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include "test_common.h"

START_TEST(test_symbol_null)
{
	int r;
	tsm_symbol_t sym = 0, s;
	const tsm_symbol_t *sp;
	unsigned int n;

	r = tsm_symbol_table_new(NULL);
	ck_assert(r == -EINVAL);

	tsm_symbol_table_ref(NULL);
	tsm_symbol_table_unref(NULL);

	sp = tsm_symbol_get(NULL, &sym, NULL);
	ck_assert(sp == &sym);

	s = tsm_symbol_append(NULL, sym, 'a');
	ck_assert(s == sym);

	n = tsm_symbol_get_width(NULL, sym);
	ck_assert(!n);
}
END_TEST

START_TEST(test_symbol_init)
{
	struct tsm_symbol_table *t;
	int r;

	r = tsm_symbol_table_new(&t);
	ck_assert(!r);

	tsm_symbol_table_unref(t);
	t = NULL;
}
END_TEST

TEST_DEFINE_CASE(misc)
	TEST(test_symbol_null)
	TEST(test_symbol_init)
TEST_END_CASE

TEST_DEFINE(
	TEST_SUITE(symbol,
		TEST_CASE(misc),
		TEST_END
	)
)
