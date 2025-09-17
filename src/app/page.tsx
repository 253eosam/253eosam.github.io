export default function Home() {
  return (
    <div className="max-w-4xl mx-auto px-6 py-12">
      <header className="mb-16">
        <h1 className="text-4xl font-bold mb-4">253eosam 기술 블로그</h1>
        <p className="text-gray-600 text-lg">
          프론트엔드 개발, 알고리즘, 개발 노트를 기록합니다
        </p>
      </header>

      <main>
        <section className="mb-12">
          <h2 className="text-2xl font-semibold mb-6">최근 포스트</h2>
          <div className="space-y-4">
            <article className="border-b pb-4">
              <h3 className="text-xl font-medium mb-2">
                <a href="#" className="hover:text-blue-600 transition-colors">
                  Proxy Pattern
                </a>
              </h3>
              <p className="text-gray-600 mb-2">
                중간에서 흐름을 제어하는 역할에 대해 알아봅니다
              </p>
              <time className="text-sm text-gray-500">2022.11.03</time>
            </article>
            <article className="border-b pb-4">
              <h3 className="text-xl font-medium mb-2">
                <a href="#" className="hover:text-blue-600 transition-colors">
                  브라우저 렌더링
                </a>
              </h3>
              <p className="text-gray-600 mb-2">
                웹 브라우저의 구조와 렌더링 과정을 살펴봅니다
              </p>
              <time className="text-sm text-gray-500">2022.10.20</time>
            </article>
            <article className="border-b pb-4">
              <h3 className="text-xl font-medium mb-2">
                <a href="#" className="hover:text-blue-600 transition-colors">
                  상태 관리
                </a>
              </h3>
              <p className="text-gray-600 mb-2">
                프론트엔드에서의 상태 관리 패턴들을 정리합니다
              </p>
              <time className="text-sm text-gray-500">2022.10.20</time>
            </article>
          </div>
        </section>

        <section>
          <h2 className="text-2xl font-semibold mb-6">카테고리</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="border rounded-lg p-6 hover:shadow-md transition-shadow">
              <h3 className="text-lg font-medium mb-2">프론트엔드</h3>
              <p className="text-gray-600 text-sm">
                React, Vue, JavaScript 등 프론트엔드 기술
              </p>
            </div>
            <div className="border rounded-lg p-6 hover:shadow-md transition-shadow">
              <h3 className="text-lg font-medium mb-2">패턴</h3>
              <p className="text-gray-600 text-sm">
                디자인 패턴과 아키텍처 패턴
              </p>
            </div>
            <div className="border rounded-lg p-6 hover:shadow-md transition-shadow">
              <h3 className="text-lg font-medium mb-2">알고리즘</h3>
              <p className="text-gray-600 text-sm">
                자료구조와 알고리즘 문제 풀이
              </p>
            </div>
          </div>
        </section>
      </main>
    </div>
  )
}
