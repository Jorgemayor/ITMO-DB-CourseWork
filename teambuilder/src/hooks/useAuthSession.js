import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';

export const STORE_KEY = 'auth-session';

export const useAuthSession = create()(
    persist(
        (set) => ({
            session: null,
            token: null,
            setSession: (session, token) => {
                set({
                    session,
                    token,
                });
            },
            logout: () => {
                set({
                    session: null,
                    token: null,
                });
            },
        }),
        {
            name: STORE_KEY,
            storage: createJSONStorage(() => localStorage),
            partialize: (state) => ({
                session: state.session,
                token: state.token,
            }),
        },
    ),
);
