import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rickmorty/layers/domain/usecase/get_all_characters.dart';
import 'package:rickmorty/layers/presentation/using_bloc/list_page/bloc/character_page_bloc.dart';

import '../../../../../../fixtures/fixtures.dart';

class MockGetAllCharacters extends Mock implements GetAllCharacters {}

void main() {
  late CharacterPageBloc bloc;
  late GetAllCharacters getAllCharacters;

  setUp(() {
    getAllCharacters = MockGetAllCharacters();
    bloc = CharacterPageBloc(getAllCharacters: getAllCharacters);
  });

  group('CharacterPageBloc', () {
    test('initial state is correct', () {
      final initial = bloc.state;
      expect(initial, const CharacterPageState());
    });

    group('.FetchNextPageEvent', () {
      blocTest<CharacterPageBloc, CharacterPageState>(
        'emits loading->success',
        build: () => bloc,
        setUp: () {
          when(() => getAllCharacters(page: 1)).thenAnswer(
            (_) async => characterList1,
          );
        },
        act: (bloc) => bloc..add(const FetchNextPageEvent()),
        expect: () => [
          const CharacterPageState(
            status: CharacterPageStatus.loading,
          ),
          CharacterPageState(
            status: CharacterPageStatus.success,
            characters: characterList1,
            hasReachedEnd: false,
            currentPage: 2,
          ),
        ],
      );

      blocTest<CharacterPageBloc, CharacterPageState>(
        'emits a state with hasReachedEnd true',
        build: () => bloc,
        setUp: () {
          when(() => getAllCharacters(page: 1)).thenAnswer(
            (_) async => const [],
          );
        },
        act: (bloc) => bloc..add(const FetchNextPageEvent()),
        expect: () => [
          const CharacterPageState(
            status: CharacterPageStatus.loading,
          ),
          const CharacterPageState(
            status: CharacterPageStatus.success,
            characters: [],
            hasReachedEnd: true,
            currentPage: 2,
          ),
        ],
      );
    });
  });
}
